-- Zephyr Spy - Install AFTER competitor's script is loaded
-- This will monitor what their exploit does in real-time
-- Usage: 
-- 1. Load competitor's script first
-- 2. Then run: loadstring(game:HttpGet("url/tools/zephyr_spy.lua"))()
-- 3. Enable their Zephyr exploit
-- 4. Use the ability and watch console

print("=== ZEPHYR SPY STARTED ===")
print("Monitoring bedwars controllers...")

-- Get bedwars
local bedwars
pcall(function()
	local Flamework = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@flamework"].core.out).Flamework
	bedwars = {
		CooldownController = Flamework.resolveDependency('@easy-games/game-core:client/controllers/cooldown/cooldown-controller@CooldownController'),
		AbilityController = Flamework.resolveDependency('@easy-games/game-core:client/controllers/ability/ability-controller@AbilityController'),
		WindWalkerController = Flamework.resolveDependency('@easy-games/game-core:client/controllers/wind-walker/wind-walker-controller@WindWalkerController'),
		Client = require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
	}
end)

if not bedwars then
	print("[ERROR] Failed to get bedwars!")
	return
end

print("[OK] Got bedwars controllers")

-- Monitor CooldownController.setOnCooldown calls
if bedwars.CooldownController and bedwars.CooldownController.setOnCooldown then
	local old = bedwars.CooldownController.setOnCooldown
	bedwars.CooldownController.setOnCooldown = function(self, ability, time, flag)
		if tostring(ability):find('wind') then
			print(string.format("[SPY] setOnCooldown('%s', %s, %s)", tostring(ability), tostring(time), tostring(flag)))
		end
		return old(self, ability, time, flag)
	end
	print("[HOOK] Hooked CooldownController.setOnCooldown")
end

-- Monitor AbilityController.useAbility calls
if bedwars.AbilityController and bedwars.AbilityController.useAbility then
	local old = bedwars.AbilityController.useAbility
	bedwars.AbilityController.useAbility = function(self, ability, ...)
		if tostring(ability):find('wind') then
			print(string.format("[SPY] useAbility('%s')", tostring(ability)))
		end
		return old(self, ability, ...)
	end
	print("[HOOK] Hooked AbilityController.useAbility")
end

-- Monitor WindWalkerController if it exists
if bedwars.WindWalkerController then
	print("[SCAN] WindWalkerController methods:")
	for k, v in pairs(bedwars.WindWalkerController) do
		if type(v) == 'function' then
			print("  - " .. tostring(k))
			
			-- Hook it
			local old = v
			bedwars.WindWalkerController[k] = function(...)
				print(string.format("[SPY] WindWalkerController.%s() called", tostring(k)))
				return old(...)
			end
		end
	end
end

-- Monitor Client:Get for wind_walker remotes
if bedwars.Client then
	local oldGet = bedwars.Client.Get
	bedwars.Client.Get = function(self, remoteName)
		local remote = oldGet(self, remoteName)
		
		-- Hook SendToServer if it's wind_walker related
		if remote and tostring(remoteName):lower():find('wind') then
			print(string.format("[SPY] Client:Get('%s')", tostring(remoteName)))
			
			if remote.SendToServer then
				local oldSend = remote.SendToServer
				remote.SendToServer = function(...)
					print(string.format("[SPY] %s:SendToServer() called", tostring(remoteName)))
					return oldSend(...)
				end
			end
			
			if remote.CallServer then
				local oldCall = remote.CallServer
				remote.CallServer = function(...)
					print(string.format("[SPY] %s:CallServer() called", tostring(remoteName)))
					return oldCall(...)
				end
			end
		end
		
		return remote
	end
	print("[HOOK] Hooked Client:Get")
end

-- Monitor character attributes
local lplr = game:GetService("Players").LocalPlayer
local function hookCharacter(char)
	if char:FindFirstChild("SetAttribute") then
		local oldSet = char.SetAttribute
		char.SetAttribute = function(self, attr, value)
			if tostring(attr):lower():find('wind') or tostring(attr):lower():find('cooldown') then
				print(string.format("[SPY] Character:SetAttribute('%s', %s)", tostring(attr), tostring(value)))
			end
			return oldSet(self, attr, value)
		end
		print("[HOOK] Hooked Character.SetAttribute")
	end
end

if lplr.Character then
	hookCharacter(lplr.Character)
end

lplr.CharacterAdded:Connect(hookCharacter)

print("=== SPY READY ===")
print("Now enable their Zephyr exploit and use the ability!")
print("Watch this console for all calls")

-- Also monitor for any new functions being called
task.spawn(function()
	while true do
		task.wait(0.5)
		
		-- Check if any orbs are being spawned
		pcall(function()
			local orbs = workspace:FindFirstChild("WindWalkerOrbs")
			if orbs then
				local count = #orbs:GetChildren()
				if count > 0 then
					print(string.format("[SPY] Found %d WindWalker orbs in workspace", count))
				end
			end
		end)
	end
end)
