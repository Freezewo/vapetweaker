local cloneref = cloneref or function(o) return o end
local httpService = cloneref(game:GetService('HttpService'))

local DUMP_FOLDER = 'dumps'
if not isfolder(DUMP_FOLDER) then
	makefolder(DUMP_FOLDER)
end

local dumpCount = 0
local oldLoadstring = loadstring

local function hookedLoadstring(source, chunkname, ...)
	if type(source) == 'string' and #source > 100 then
		dumpCount = dumpCount + 1
		local filename = string.format('%s/dump_%d_%s.lua', 
			DUMP_FOLDER, 
			dumpCount, 
			chunkname and tostring(chunkname):gsub('[^%w]', '_') or 'unknown'
		)
		writefile(filename, source)
		warn(string.format('[DUMP] #%d | %d bytes | %s', dumpCount, #source, filename))
	end
	return oldLoadstring(source, chunkname, ...)
end

local oldRequire = require
local function hookedRequire(module, ...)
	if typeof(module) == 'Instance' and module:IsA('ModuleScript') then
		local success, source = pcall(function()
			return decompile(module)
		end)
		if success and source and #source > 100 then
			dumpCount = dumpCount + 1
			local filename = string.format('%s/require_%d_%s.lua', 
				DUMP_FOLDER, 
				dumpCount, 
				module:GetFullName():gsub('[^%w]', '_')
			)
			writefile(filename, source)
		end
	end
	return oldRequire(module, ...)
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
			dumpCount = dumpCount + 1
			local safeName = tostring(url):gsub('[^%w]', '_'):sub(1, 80)
			local filename = string.format('%s/http_%d_%s.lua', DUMP_FOLDER, dumpCount, safeName)
			writefile(filename, result)
		end
		return result
	end
	return oldNamecall(self, ...)
end)
setreadonly(mt, true)

loadstring = newcclosure(hookedLoadstring)
if hookfunction then
	hookfunction(oldLoadstring, hookedLoadstring)
end

shared.DumperCleanup = function()
	loadstring = oldLoadstring
	local mt2 = getrawmetatable(game)
	setreadonly(mt2, false)
	mt2.__namecall = oldNamecall
	setreadonly(mt2, true)
end
