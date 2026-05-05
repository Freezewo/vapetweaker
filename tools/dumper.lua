local cloneref = cloneref or function(o) return o end
local DUMP_FOLDER = 'dumps'
if not isfolder(DUMP_FOLDER) then
	makefolder(DUMP_FOLDER)
end

local dumpCount = 0
local dumped = {}

local function safeDump(name, source)
	if not source or #source < 50 then return end
	local hash = tostring(#source) .. '_' .. source:sub(1, 64)
	if dumped[hash] then return end
	dumped[hash] = true
	dumpCount = dumpCount + 1
	local filename = string.format('%s/%s_%d.lua', DUMP_FOLDER, name, dumpCount)
	writefile(filename, source)
	warn(string.format('[D] #%d | %d bytes | %s', dumpCount, #source, filename))
end

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
	local method = getnamecallmethod()
	if method == 'HttpGet' or method == 'HttpGetAsync' then
		local url = select(1, ...)
		local result = oldNamecall(self, ...)
		if type(result) == 'string' and #result > 100 then
			local safeName = tostring(url):gsub('[^%w]', '_'):sub(1, 60)
			safeDump('http_' .. safeName, '-- ' .. tostring(url) .. '\n\n' .. result)
		end
		return result
	end
	return oldNamecall(self, ...)
end)
setreadonly(mt, true)

local oldLoadstring = loadstring
loadstring = newcclosure(function(source, chunkname, ...)
	if type(source) == 'string' and #source > 100 then
		local tag = chunkname and tostring(chunkname):gsub('[^%w]', '_') or 'chunk'
		safeDump('ls_' .. tag, source)
	end
	return oldLoadstring(source, chunkname, ...)
end)
if hookfunction then
	hookfunction(oldLoadstring, loadstring)
end

shared.GCDump = function(filter)
	local count = 0
	for _, v in getgc(true) do
		if type(v) == 'function' and not is_synapse_function(v) and islclosure(v) then
			local ok, src = pcall(decompile, v)
			if ok and src and #src > 200 then
				local info = debug.getinfo(v)
				local name = info and info.name or info and info.short_src or 'anon'
				name = tostring(name):gsub('[^%w]', '_'):sub(1, 40)
				if filter and not src:lower():find(filter:lower()) then continue end
				safeDump('gc_' .. name, src)
				count = count + 1
			end
		end
	end
	warn(string.format('[D] GC scan done: %d functions dumped', count))
end

shared.TableDump = function(tbl, name)
	name = name or 'table'
	if type(tbl) ~= 'table' then return end
	for k, v in pairs(tbl) do
		if type(v) == 'function' then
			local ok, src = pcall(decompile, v)
			if ok and src and #src > 100 then
				safeDump(name .. '_' .. tostring(k):gsub('[^%w]', '_'), src)
			end
		elseif type(v) == 'table' and v ~= tbl then
			for k2, v2 in pairs(v) do
				if type(v2) == 'function' then
					local ok, src = pcall(decompile, v2)
					if ok and src and #src > 100 then
						safeDump(name .. '_' .. tostring(k) .. '_' .. tostring(k2):gsub('[^%w]', '_'), src)
					end
				end
			end
		end
	end
end

shared.EnvDump = function()
	for k, v in pairs(getgenv()) do
		if type(v) == 'function' and islclosure(v) then
			local ok, src = pcall(decompile, v)
			if ok and src and #src > 200 then
				safeDump('env_' .. tostring(k):gsub('[^%w]', '_'), src)
			end
		elseif type(v) == 'table' and type(k) == 'string' then
			shared.TableDump(v, 'env_' .. k)
		end
	end
	for k, v in pairs(shared) do
		if type(v) == 'table' then
			shared.TableDump(v, 'shared_' .. tostring(k))
		end
	end
	warn('[D] Env dump done')
end

shared.DumperCleanup = function()
	loadstring = oldLoadstring
	setreadonly(mt, false)
	mt.__namecall = oldNamecall
	setreadonly(mt, true)
end
