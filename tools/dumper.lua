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
	pcall(writefile, filename, source)
end

local oldLoadstring = loadstring
getgenv().loadstring = function(source, chunkname, ...)
	if type(source) == 'string' and #source > 100 then
		local tag = chunkname and tostring(chunkname):gsub('[^%w]', '_') or 'chunk'
		safeDump('ls_' .. tag, source)
	end
	return oldLoadstring(source, chunkname, ...)
end

shared.GCDump = function(filter)
	local count = 0
	for _, v in getgc(true) do
		pcall(function()
			if type(v) == 'function' and islclosure(v) then
				local ok, src = pcall(decompile, v)
				if ok and src and #src > 200 then
					local info = debug.getinfo(v)
					local name = info and info.name or 'anon'
					if name == '' then name = 'anon' end
					name = tostring(name):gsub('[^%w]', '_'):sub(1, 40)
					if filter and not src:lower():find(filter:lower()) then return end
					safeDump('gc_' .. name, src)
					count = count + 1
				end
			end
		end)
	end
	warn('[D] ' .. count .. ' functions dumped')
end

shared.DumperCleanup = function()
	getgenv().loadstring = oldLoadstring
end
