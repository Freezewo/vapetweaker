--!nocheck
-- Anti-Dump Protection
local function checkDumper()
	local isDumping = false
	
	-- Проверка 1: Хук на loadstring (дампер перехватывает loadstring)
	local originalLoadstring = loadstring
	if getgenv().loadstring and getgenv().loadstring ~= originalLoadstring then
		isDumping = true
	end
	
	-- Проверка 2: Активные dump функции в shared
	if shared.GCDump or shared.ScanShared or shared.FindURLs or shared.DumperCleanup then
		isDumping = true
	end
	
	-- Проверка 3: Проверяем активное создание dumps папки + файлов
	if isfolder and isfolder('dumps') then
		local files = listfiles and listfiles('dumps') or {}
		-- Если в папке dumps есть свежие файлы (созданные недавно)
		if #files > 0 then
			isDumping = true
		end
	end
	
	if isDumping then
		warn('[VapeTweaker] Dumper detected! Kicking player...')
		game:GetService('Players').LocalPlayer:Kick('\n[VapeTweaker Anti-Dump]\n\nDumper detected!\nPlease disable any dumping tools and try again.')
		return false
	end
	
	return true
end

if not checkDumper() then
	return
end

shared.catdata = {Key = script_key or 'none'}
getgenv().catrole = 'Premium'
getgenv().catname = 'VapeTweaker User'
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local delfile = delfile or function(file)
	writefile(file, '')
end

local downloader = Instance.new('TextLabel')
downloader.Size = UDim2.new(1, 0, 0, 40)
downloader.BackgroundTransparency = 1
downloader.TextStrokeTransparency = 0
downloader.TextSize = 20
downloader.TextColor3 = Color3.new(1, 1, 1)
downloader.Font = Enum.Font.Arial
downloader.Text = ''
downloader.Parent = Instance.new('ScreenGui', gethui and gethui() or game:GetService('CoreGui'))

local function downloadFile(path, func)
	if not isfile(path) then
		downloader.Text = 'Downloading '.. path
		
		-- Encrypted GitHub URL
		local base = table.concat({
			string.char(104,116,116,112,115,58,47,47),
			string.char(114,97,119,46,103,105,116,104,117,98),
			string.char(117,115,101,114,99,111,110,116,101,110,116),
			string.char(46,99,111,109,47,70,114,101,101,122,101,119,111,47),
			string.char(118,97,112,101,116,119,101,97,107,101,114,47)
		})
		
		local url = base..readfile('vapetweaker/profiles/commit.txt')..'/'..select(1, path:gsub('vapetweaker/', ''))
		
		local suc, res = pcall(function()
			return game:HttpGet(url, true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
		downloader.Text = ''
	end
	return (func or readfile)(path)
end

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in listfiles(path) do
		if file:find('init') then continue end
		if file:find('profile') then continue end
		if isfile(file) then
			delfile(file)
		elseif isfolder(file) then
			wipeFolder(file)
		end
	end
end


for _, folder in {'vapetweaker', 'vapetweaker/games', 'vapetweaker/profiles', 'vapetweaker/assets', 'vapetweaker/libraries', 'vapetweaker/guis'} do
	if not isfolder(folder) then
		downloader.Text = 'Downloading '.. folder
		makefolder(folder)
	end
end

if not shared.VapeDeveloper then
	local _, subbed = pcall(function()
		-- Encrypted GitHub URL
		local url = table.concat({
			string.char(104,116,116,112,115,58,47,47),
			string.char(103,105,116,104,117,98,46,99,111,109,47),
			string.char(70,114,101,101,122,101,119,111,47),
			string.char(118,97,112,101,116,119,101,97,107,101,114)
		})
		return game:HttpGet(url)
	end)
	local commit = subbed:find('currentOid')
	commit = commit and subbed:sub(commit + 13, commit + 52) or nil
	commit = commit and #commit == 40 and commit or 'main'
	if commit == 'main' or (isfile('vapetweaker/profiles/commit.txt') and readfile('vapetweaker/profiles/commit.txt') or '') ~= commit then
		if commit ~= 'main' and isfile('vapetweaker/profiles/commit.txt') then
			shared.updated = readfile('vapetweaker/profiles/commit.txt')
		end
		wipeFolder('vapetweaker')
		wipeFolder('vapetweaker/games')
		wipeFolder('vapetweaker/guis')
		wipeFolder('vapetweaker/libraries')
	end
	writefile('vapetweaker/profiles/commit.txt', commit)
end

downloader.Text = ''
return loadstring(downloadFile('vapetweaker/main.lua'), 'main')()
