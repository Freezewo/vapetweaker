-- Zephyr Ability Dumper
-- Run this BEFORE loading competitor's script to see what they do
-- Usage: loadstring(game:HttpGet("your_url/tools/zephyr_dumper.lua"))()

local logFile = {}
local logCount = 0

local function log(category, message)
	logCount = logCount + 1
	local entry = string.format("[%d] [%s] %s", logCount, category, message)
	table.insert(logFile, entry)
	print(entry)
	
	-- Also show notification if vape exists
	pcall(function()
		if vape and vape.CreateNotification then
			vape:CreateNotification('DUMP', message, 3, 'info')
		end
	end)
end

log("INIT", "=== ZEPHYR DUMPER STARTED ===")
log("INIT", "This will log ALL calls related to abilities/cooldowns")

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

-- Hook CooldownController
if bedwars.CooldownController then
	log("HOOK", "Hooking CooldownController methods...")
	
	-- List all methods
	for k, v in pairs(bedwars.CooldownController) do
		if type(v) == 'function' then
			log("METHOD", "CooldownController." .. tostring(k))
			
			-- Hook it
			local old = v
			bedwars.CooldownController[k] = function(...)
				local args = {...}
				local argStr = ""
				for i, arg in ipairs(args) do
					if i > 1 then argStr = argStr .. ", " end
					argStr = argStr .. tostring(arg)
				end
				log("CALL", string.format("CooldownController:%s(%s)", tostring(k), argStr))
				return old(...)
			end
		end
	end
end

-- Hook AbilityController
if bedwars.AbilityController then
	log("HOOK", "Hooking AbilityController methods...")
	
	for k, v in pairs(bedwars.AbilityController) do
		if type(v) == 'function' then
			log("METHOD", "AbilityController." .. tostring(k))
			
			local old = v
			bedwars.AbilityController[k] = function(...)
				local args = {...}
				local argStr = ""
				for i, arg in ipairs(args) do
					if i > 1 then argStr = argStr .. ", " end
					argStr = argStr .. tostring(arg)
				end
				log("CALL", string.format("AbilityController:%s(%s)", tostring(k), argStr))
				return old(...)
			end
		end
	end
end

-- Hook Client:Get calls
if bedwars.Client then
	log("HOOK", "Hooking Client:Get...")
	
	local oldGet = bedwars.Client.Get
	bedwars.Client.Get = function(self, remoteName)
		log("REMOTE", "Client:Get('" .. tostring(remoteName) .. "')")
		local remote = oldGet(self, remoteName)
		
		-- Hook the remote's methods
		if remote then
			pcall(function()
				if remote.SendToServer then
					local oldSend = remote.SendToServer
					remote.SendToServer = function(...)
						local args = {...}
						local argStr = ""
						for i, arg in ipairs(args) do
							if i > 1 then argStr = argStr .. ", " end
							if type(arg) == 'table' then
								argStr = argStr .. "table"
							else
								argStr = argStr .. tostring(arg)
							end
						end
						log("SEND", string.format("%s:SendToServer(%s)", tostring(remoteName), argStr))
						return oldSend(...)
					end
				end
				
				if remote.CallServer then
					local oldCall = remote.CallServer
					remote.CallServer = function(...)
						local args = {...}
						local argStr = ""
						for i, arg in ipairs(args) do
							if i > 1 then argStr = argStr .. ", " end
							if type(arg) == 'table' then
								argStr = argStr .. "table"
							else
								argStr = argStr .. tostring(arg)
							end
						end
						log("CALL", string.format("%s:CallServer(%s)", tostring(remoteName), argStr))
						return oldCall(...)
					end
				end
			end)
		end
		
		return remote
	end
end

-- Hook character attributes
local lplr = game:GetService("Players").LocalPlayer
if lplr.Character then
	log("HOOK", "Hooking character attributes...")
	
	local oldSetAttribute = lplr.Character.SetAttribute
	lplr.Character.SetAttribute = function(self, attr, value)
		if tostring(attr):lower():find('wind') or tostring(attr):lower():find('zephyr') or tostring(attr):lower():find('cooldown') then
			log("ATTR", string.format("Character:SetAttribute('%s', %s)", tostring(attr), tostring(value)))
		end
		return oldSetAttribute(self, attr, value)
	end
end

log("INIT", "=== ALL HOOKS INSTALLED ===")
log("INIT", "Now load competitor's script and use their Zephyr exploit")
log("INIT", "Watch the console/notifications for all calls!")

-- Function to dump log to file
_G.dumpZephyrLog = function()
	local str = table.concat(logFile, "\n")
	print("=== FULL LOG ===")
	print(str)
	print("=== END LOG ===")
	return str
end

log("INIT", "Use _G.dumpZephyrLog() to print full log")
