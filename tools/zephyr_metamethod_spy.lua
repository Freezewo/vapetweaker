-- Zephyr Metamethod Spy - Uses hookmetamethod to catch ALL function calls
-- Run AFTER competitor's script
-- This is the most aggressive approach

print("=== ZEPHYR METAMETHOD SPY ===")

local callLog = {}
local logCount = 0

local function shouldLog(name)
	if not name then return false end
	local n = tostring(name):lower()
	return n:find('wind') or n:find('zephyr') or n:find('cooldown') or n:find('ability') or n:find('orb')
end

-- Hook __namecall
local old_namecall
old_namecall = hookmetamethod(game, "__namecall", function(self, ...)
	local method = getnamecallmethod()
	local args = {...}
	
	-- Log interesting calls
	if shouldLog(method) or shouldLog(tostring(self)) then
		logCount = logCount + 1
		local msg = string.format("[%d] %s:%s()", logCount, tostring(self), method)
		print(msg)
		table.insert(callLog, msg)
	end
	
	-- Special logging for specific methods
	if method == "FireServer" or method == "InvokeServer" or method == "SendToServer" then
		local remoteName = tostring(self)
		if shouldLog(remoteName) then
			logCount = logCount + 1
			local msg = string.format("[%d] REMOTE: %s:%s", logCount, remoteName, method)
			print(msg)
			table.insert(callLog, msg)
			
			-- Log arguments
			for i, arg in ipairs(args) do
				if type(arg) == 'table' then
					print(string.format("  arg[%d] = table", i))
				else
					print(string.format("  arg[%d] = %s", i, tostring(arg)))
				end
			end
		end
	end
	
	return old_namecall(self, ...)
end)

print("[HOOK] Hooked __namecall")

-- Hook __index to catch property reads
local old_index
old_index = hookmetamethod(game, "__index", function(self, key)
	if shouldLog(key) or shouldLog(tostring(self)) then
		-- Don't log too much, just important ones
		if tostring(key):find('Controller') or tostring(key):find('setOnCooldown') or tostring(key):find('spawnOrb') then
			logCount = logCount + 1
			local msg = string.format("[%d] INDEX: %s.%s", logCount, tostring(self), tostring(key))
			print(msg)
			table.insert(callLog, msg)
		end
	end
	
	return old_index(self, key)
end)

print("[HOOK] Hooked __index")

-- Monitor workspace for orbs
task.spawn(function()
	while true do
		task.wait(1)
		pcall(function()
			-- Check for wind walker orbs
			for _, obj in ipairs(workspace:GetDescendants()) do
				if tostring(obj.Name):lower():find('wind') or tostring(obj.Name):lower():find('orb') then
					if obj:IsA("Part") or obj:IsA("Model") then
						logCount = logCount + 1
						local msg = string.format("[%d] FOUND: %s in workspace", logCount, obj:GetFullName())
						print(msg)
						table.insert(callLog, msg)
					end
				end
			end
		end)
	end
end)

print("=== SPY READY ===")
print("Enable their exploit and use ability!")
print("All wind_walker/zephyr/cooldown calls will be logged")

_G.dumpSpyLog = function()
	print("=== FULL SPY LOG ===")
	for _, line in ipairs(callLog) do
		print(line)
	end
	print("=== END LOG ===")
end

print("Use _G.dumpSpyLog() to see full log")
