-- Zephyr Ability Dumper v2 - Silent mode
-- Run this BEFORE loading competitor's script to see what they do
-- Usage: loadstring(game:HttpGet("your_url/tools/zephyr_dumper.lua"))()

local logFile = {}
local logCount = 0

local function log(category, message)
	logCount = logCount + 1
	local entry = string.format("[%d] [%s] %s", logCount, category, message)
	table.insert(logFile, entry)
	print(entry)
end

log("INIT", "=== ZEPHYR DUMPER V2 STARTED (SILENT MODE) ===")

-- Get bedwars
local bedwars
pcall(function()
	local Flamework = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@flamework"].core.out).Flamework
	bedwars = {
		CooldownController = Flamework.resolveDependency('@easy-games/game-core:client/controllers/cooldown/cooldown-controller@CooldownController'),
		AbilityController = Flamework.resolveDependency('@easy-games/game-core:client/controllers/ability/ability-controller@AbilityController'),
		Client = require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
	}
end)

if not bedwars then
	log("ERROR", "Failed to get bedwars controllers!")
	return
end

log("INIT", "Got bedwars controllers")

-- Store original functions without hooking (to avoid conflicts)
local originals = {}

-- Just log what methods exist
if bedwars.CooldownController then
	log("SCAN", "CooldownController methods:")
	for k, v in pairs(bedwars.CooldownController) do
		if type(v) == 'function' then
			log("METHOD", "  - " .. tostring(k))
			originals["CooldownController." .. k] = v
		end
	end
end

if bedwars.AbilityController then
	log("SCAN", "AbilityController methods:")
	for k, v in pairs(bedwars.AbilityController) do
		if type(v) == 'function' then
			log("METHOD", "  - " .. tostring(k))
			originals["AbilityController." .. k] = v
		end
	end
end

-- Lightweight hook only for Client:Get
if bedwars.Client then
	log("HOOK", "Installing lightweight Client:Get hook...")
	
	local oldGet = bedwars.Client.Get
	bedwars.Client.Get = function(self, remoteName)
		-- Only log wind_walker related remotes
		if tostring(remoteName):lower():find('wind') or tostring(remoteName):lower():find('zephyr') then
			log("REMOTE", "Client:Get('" .. tostring(remoteName) .. "')")
		end
		return oldGet(self, remoteName)
	end
end

log("INIT", "=== DUMPER READY (LIGHTWEIGHT MODE) ===")
log("INIT", "Now load competitor's script")
log("INIT", "Use _G.dumpZephyrLog() to see full log")

-- Function to dump log
_G.dumpZephyrLog = function()
	local str = table.concat(logFile, "\n")
	print("=== FULL LOG ===")
	print(str)
	print("=== END LOG ===")
	return str
end

-- Monitor for new functions being added
task.spawn(function()
	task.wait(5)
	log("MONITOR", "Checking for new hooks after 5 seconds...")
	
	if bedwars.CooldownController then
		for k, v in pairs(bedwars.CooldownController) do
			if type(v) == 'function' and not originals["CooldownController." .. k] then
				log("NEW", "NEW METHOD: CooldownController." .. tostring(k))
			end
		end
	end
	
	if bedwars.AbilityController then
		for k, v in pairs(bedwars.AbilityController) do
			if type(v) == 'function' and not originals["AbilityController." .. k] then
				log("NEW", "NEW METHOD: AbilityController." .. tostring(k))
			end
		end
	end
end)

