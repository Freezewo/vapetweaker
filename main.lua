repeat task.wait() until game:IsLoaded()
if shared.vape then shared.vape:Uninject() end

local vape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
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

if shared.maincat then
	shared.maincat = nil
	task.spawn(function()
		local body = httpService:JSONEncode({
			nonce = httpService:GenerateGUID(false),
			args = {
				invite = {code = 'vapetweaker'},
				code = 'vapetweaker'
			},
			cmd = 'INVITE_BROWSER'
		})

		for i = 1, 2 do
			task.spawn(function()
				request({
					Method = 'POST',
					Url = 'http://127.0.0.1:6463/rpc?v=1',
					Headers = {
						['Content-Type'] = 'application/json',
						Origin = 'https://discord.com'
					},
					Body = body
				})
			end)
		end
	end)
	playersService:Kick('Your script is outdated, Get new one at discord.gg/vapetweaker')
	return
end

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/Freezewo/vapetweaker/'..readfile('vapetweaker/profiles/commit.txt')..'/'..select(1, path:gsub('vapetweaker/', '')), true)
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
			local data = shared.catdata or {Key = nil}
			local teleportScript = [[
				if shared.VapeDeveloper then
					shared.catdata = {Key = '???'}
					print('yo', shared.catdata.Key)
					loadstring(readfile('vapetweaker/init.lua'), 'init')()
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/Freezewo/vapetweaker/main/init.lua'), 'init')()
				end
			]]
			teleportScript = teleportScript:gsub('???', tostring(data.Key or 'none'))
			if shared.VapeDeveloper then
				teleportScript = 'shared.VapeDeveloper = true\n'..teleportScript
			end
			if shared.VapeCustomProfile then
				teleportScript = 'shared.VapeCustomProfile = "'..shared.VapeCustomProfile..'"\n'..teleportScript
			end
			vape:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not vape.Categories then return end
	if vape.Place ~= 6872274481 and vape.Notifications.Enabled then
		task.spawn(function()
			local body = httpService:JSONEncode({
				nonce = httpService:GenerateGUID(false),
				args = {
					invite = {code = 'vapetweaker'},
					code = 'vapetweaker'
				},
				cmd = 'INVITE_BROWSER'
			})

			for i = 1, 2 do
				task.spawn(function()
					request({
						Method = 'POST',
						Url = 'http://127.0.0.1:6463/rpc?v=1',
						Headers = {
							['Content-Type'] = 'application/json',
							Origin = 'https://discord.com'
						},
						Body = body
					})
				end)
			end
		end)
	end
	if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
		if getgenv().catrole == 'HWID mismatch' then
			vape:CreateNotification('Cat', 'HWID mismatch, Please go to our server And press reset hwid on script panel', 60, 'alert')
			task.wait(0.5)
		else
			vape:CreateNotification('Cat', 'Authenticated as '.. (getgenv().catname or 'Guest').. ' with ('.. (getgenv().catrole or 'Free').. ')', 4, 'info')
			task.wait(4)
		end
		vape:CreateNotification('Finished Loading', not inputService.KeyboardEnabled and vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(vape.Keybind, ' + '):upper()..' to open GUI', 5)
	end
end

if not isfile('vapetweaker/profiles/gui.txt') then
	writefile('vapetweaker/profiles/gui.txt', 'new')
end
local gui = 'new'--readfile('vapetweaker/profiles/gui.txt')

if not isfolder('vapetweaker/assets/'..gui) then
	makefolder('vapetweaker/assets/'..gui)
end
vape = loadstring(downloadFile('vapetweaker/guis/'..gui..'.lua'), 'gui')()
shared.vape = vape
_G.vape = vape

getgenv().canDebug = not table.find({'Xeno', 'Solara'}, ({identifyexecutor()})[1]) and debug.getconstant and debug.getproto and true or false

-- PREMIUM DUMPER - встроенный
if getgenv().DumpPremium then
	warn('[DUMPER] ===== PREMIUM DUMP ENABLED =====')
	
	local DUMP_FOLDER = 'vapetweaker/dumps'
	pcall(function()
		if not isfolder('vapetweaker') then makefolder('vapetweaker') end
		if not isfolder(DUMP_FOLDER) then makefolder(DUMP_FOLDER) end
		warn('[DUMPER] Folder created')
	end)
	
	-- Перехват loadstring
	local oldLoadstring = loadstring
	loadstring = function(source, chunkname, ...)
		pcall(function()
			if type(source) == 'string' and #source > 100 then
				local tag = tostring(chunkname or '')
				if tag:find('paid') or tag:find('premium') then
					warn('[DUMPER] !!! PREMIUM CAUGHT !!!')
					writefile(DUMP_FOLDER .. '/premium_raw.lua', source)
					warn('[DUMPER] Saved premium code!')
				end
			end
		end)
		return oldLoadstring(source, chunkname, ...)
	end
	
	-- Перехват модулей
	task.spawn(function()
		repeat task.wait(0.5) until shared.vape and shared.vape.Categories
		warn('[DUMPER] Hooking modules...')
		
		for catName, cat in pairs(shared.vape.Categories) do
			if cat.CreateModule then
				local old = cat.CreateModule
				cat.CreateModule = function(self, opt)
					if opt and opt.Name then
						warn('[DUMPER] Module:', opt.Name)
						if opt.Tags and table.find(opt.Tags, 'new') then
							warn('[DUMPER] !!! NEW:', opt.Name, '!!!')
						end
					end
					return old(self, opt)
				end
			end
		end
		warn('[DUMPER] Hooks installed!')
	end)
end

if not shared.VapeIndependent then
	loadstring(downloadFile('vapetweaker/games/universal.lua'), 'universal')()

	-- Load dumper BEFORE premium loads
	if shared.VapeDeveloper or getgenv().DumpPremium then
		pcall(function()
			loadstring(readfile('vapetweaker/tools/advanced_dumper.lua'), 'dumper')()
			warn('[VapeTweaker] Advanced dumper loaded!')
		end)
	end
	
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
					
					loadstring(callback('vapetweaker/games/'.. i.. '/'.. i2.. '.luau'), tostring(game.PlaceId))(...)
					loadstring(callback('vapetweaker/games/'.. i.. '/'.. 'premium'.. '.luau'), 'paid '.. tostring(game.PlaceId))(...)
					break
				end
			end
		end
	end

	if not found then
		local suc, res = pcall(function()
			return not shared.VapeDeveloper and game:HttpGet('https://raw.githubusercontent.com/Freezewo/vapetweaker/'..readfile('vapetweaker/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true) or '404: Not Found'
		end)
		if suc and res ~= '404: Not Found' then
			loadstring(downloadFile('vapetweaker/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
		end
	end
	
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end