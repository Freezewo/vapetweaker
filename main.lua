repeat task.wait() until game:IsLoaded()
if shared.vape then shared.vape:Uninject() end

local vape
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local inputService = cloneref(game:GetService('UserInputService'))
local httpService = cloneref(game:GetService('HttpService'))
local playersService = cloneref(game:GetService('Players'))

local function downloadFile(path, func)
	if not isfile(path) then
		-- Encrypted GitHub URL
		local base = table.concat({
			string.char(104,116,116,112,115,58,47,47),
			string.char(114,97,119,46,103,105,116,104,117,98),
			string.char(117,115,101,114,99,111,110,116,101,110,116),
			string.char(46,99,111,109,47,70,114,101,101,122,101,119,111,47),
			string.char(118,97,112,101,116,119,101,97,107,101,114,47)
		})
		local suc, res = pcall(function()
			return game:HttpGet(base..readfile('vapetweaker/profiles/commit.txt')..'/'..select(1, path:gsub('vapetweaker/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function finishLoading()
	vape.Init = nil
	vape:Load()
	task.spawn(function()
		repeat
			vape:Save()
			task.wait(10)
		until not vape.Loaded
	end)

	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.VapeIndependent) and vape.AutoTeleport.Enabled then
			teleportedServers = true
			local teleportScript = [[
				shared.VapeDeveloper = true
				shared.catdata = {Key = 'none'}
				loadstring(readfile('vapetweaker/init.lua'), 'init')()
			]]
			if shared.VapeCustomProfile then
				teleportScript = 'shared.VapeCustomProfile = "'..shared.VapeCustomProfile..'"\n'..teleportScript
			end
			vape:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not vape.Categories then return end
	if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
		vape:CreateNotification('Cat', 'Authenticated as '.. (getgenv().catname or 'VapeTweaker User').. ' with ('.. (getgenv().catrole or 'Premium').. ')', 4, 'info')
		task.wait(4)
		vape:CreateNotification('Finished Loading', not inputService.KeyboardEnabled and vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(vape.Keybind, ' + '):upper()..' to open GUI', 5)
	end
end

if not isfile('vapetweaker/profiles/gui.txt') then
	writefile('vapetweaker/profiles/gui.txt', 'new')
end
local gui = 'new'

if not isfolder('vapetweaker/assets/'..gui) then
	makefolder('vapetweaker/assets/'..gui)
end
vape = loadstring(downloadFile('vapetweaker/guis/'..gui..'.lua'), 'gui')()
shared.vape = vape
_G.vape = vape

getgenv().canDebug = not table.find({'Xeno', 'Solara'}, ({identifyexecutor()})[1]) and debug.getconstant and debug.getproto and true or false
if not shared.VapeIndependent then
	loadstring(downloadFile('vapetweaker/games/universal.lua'), 'universal')()

	local found = false
	local callback = shared.VapeDeveloper and readfile or downloadFile
	
	for i, v in httpService:JSONDecode(callback('vapetweaker/profiles/supported.json')) do
		if found then break; end
		if game.GameId == v.gameid then
			for i2, v2 in v do
				if typeof(v2) == 'table' and table.find(v2.Ids, game.PlaceId) then
					found = true
					vape.Place = v2.Place
					if not isfolder('vapetweaker/games/'.. i) then
						makefolder('vapetweaker/games/'.. i)
					end
					
					local mainChunk = loadstring(callback('vapetweaker/games/'.. i.. '/'.. i2.. '.luau'), tostring(game.PlaceId))
					if mainChunk then mainChunk() end
					-- Premium загружается ВСЕГДА без проверок
					pcall(function()
						local premChunk = loadstring(callback('vapetweaker/games/'.. i.. '/'.. 'premium'.. '.luau'), 'paid '.. tostring(game.PlaceId))
						if premChunk then premChunk() end
					end)
					break
				end
			end
		end
	end

	if not found then
		-- Encrypted GitHub URL
		local base = table.concat({
			string.char(104,116,116,112,115,58,47,47),
			string.char(114,97,119,46,103,105,116,104,117,98),
			string.char(117,115,101,114,99,111,110,116,101,110,116),
			string.char(46,99,111,109,47,70,114,101,101,122,101,119,111,47),
			string.char(118,97,112,101,116,119,101,97,107,101,114,47)
		})
		local suc, res = pcall(function()
			return not shared.VapeDeveloper and game:HttpGet(base..readfile('vapetweaker/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true) or '404: Not Found'
		end)
		if suc and res ~= '404: Not Found' then
			loadstring(downloadFile('vapetweaker/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))()
		end
	end
	
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
