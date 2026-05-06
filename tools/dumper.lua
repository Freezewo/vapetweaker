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
	task.spawn(function()
		local count = 0
		local scanned = 0
		for _, v in getgc(true) do
			pcall(function()
				if type(v) == 'function' then
					local ok, src = pcall(decompile, v)
					if ok and src and #src > 200 then
						local info = pcall(debug.getinfo, v) and debug.getinfo(v)
						local name = info and info.name or 'anon'
						if name == '' then name = 'anon' end
						name = tostring(name):gsub('[^%w]', '_'):sub(1, 40)
						if filter and not src:lower():find(filter:lower()) then return end
						safeDump('gc_' .. name, src)
						count = count + 1
					end
				end
			end)
			scanned = scanned + 1
			if scanned % 100 == 0 then task.wait() end
		end
		warn('[D] ' .. count .. '/' .. scanned .. ' dumped')
	end)
end

shared.ScanShared = function()
	local count = 0
	local function scanTable(t, prefix, depth)
		if depth > 3 then return end
		for k, v in pairs(t) do
			pcall(function()
				local key = prefix .. tostring(k)
				if type(v) == 'function' then
					local ok, src = pcall(decompile, v)
					if ok and src and #src > 100 then
						safeDump('shared_' .. key:gsub('[^%w]', '_'):sub(1, 50), src)
						count = count + 1
					end
				elseif type(v) == 'table' and v ~= t and v ~= shared and v ~= _G then
					scanTable(v, key .. '_', depth + 1)
				end
			end)
		end
	end
	scanTable(shared, '', 0)
	scanTable(getgenv(), 'genv_', 0)
	warn('[D] shared scan: ' .. count .. ' functions')
end

shared.FindURLs = function()
	local files = listfiles(DUMP_FOLDER)
	local urls = {}
	for _, f in pairs(files) do
		pcall(function()
			local content = readfile(f)
			for url in content:gmatch('https?://[%w%.%-_/%%%?%&%=%+]+') do
				if not urls[url] then
					urls[url] = true
					warn('[URL] ' .. url)
				end
			end
			local hex = content:gsub('%s+', '')
			if hex:match('^[0-9A-Fa-f]+$') and #hex > 200 then
				local decoded = ''
				for i = 1, #hex, 2 do
					local byte = tonumber(hex:sub(i, i+1), 16)
					if byte then decoded = decoded .. string.char(byte) end
				end
				for url in decoded:gmatch('https?://[%w%.%-_/%%%?%&%=%+]+') do
					if not urls[url] then
						urls[url] = true
						warn('[URL-HEX] ' .. url)
					end
				end
				safeDump('hex_decoded', decoded)
			end
		end)
	end
end

shared.DumperCleanup = function()
	getgenv().loadstring = oldLoadstring
end
