--!nocheck
-- Anti-Dump Protection
local function checkDumper()
	local dangerousFuncs = {
		'getgc', 'getgenv', 'getrenv', 'getloadedmodules',
		'debug.getupvalue', 'debug.getupvalues', 'debug.getconstants',
		'debug.getinfo', 'debug.getproto', 'debug.getprotos',
		'getscriptbytecode', 'getscriptclosure', 'dumpstring',
		'saveinstance', 'writefile'
	}
	
	local suspiciousActivity = 0
	
	for _, funcName in dangerousFuncs do
		local func = loadstring('return '..funcName)
		if func and pcall(func) then
			suspiciousActivity = suspiciousActivity + 1
		end
	end
	
	if suspiciousActivity >= 5 then
		local caller = debug.info(2, 's')
		if caller and not caller:find('vapetweaker') then
			warn('[VapeTweaker] Dumper detected! Kicking player...')
			game:GetService('Players').LocalPlayer:Kick('\n[VapeTweaker Anti-Dump]\n\nDumper detected!\nPlease disable any dumping tools and try again.')
			return false
		end
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
		return game:HttpGet('https://github.com/Freezewo/vapetweaker') 
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