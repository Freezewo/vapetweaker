-- Premium Function Decompiler
-- Декомпилирует функции из premium модулей

local httpService = game:GetService('HttpService')
local DUMP_FOLDER = 'vapetweaker/dumps/decompiled'

warn('[DECOMPILER] ===== STARTING DECOMPILATION =====')

-- Создаём папку
pcall(function()
	if not isfolder('vapetweaker') then makefolder('vapetweaker') end
	if not isfolder('vapetweaker/dumps') then makefolder('vapetweaker/dumps') end
	if not isfolder(DUMP_FOLDER) then makefolder(DUMP_FOLDER) end
	warn('[DECOMPILER] Folder created:', DUMP_FOLDER)
end)

-- Проверяем decompile
if not decompile then
	warn('[DECOMPILER] ERROR: Your executor does not support decompile!')
	warn('[DECOMPILER] Try using: Synapse X, Script-Ware, or Electron')
	return
end

local decompiled = {}
local targetModules = {
	'BackTrack',
	'Bed Assist',
	'Disabler',
	'Fake Lag',
	'Owl Aura',
	'Auto Farm Macro'
}

-- Перехватываем CreateModule
task.spawn(function()
	repeat task.wait(0.5) until shared.vape and shared.vape.Categories
	
	warn('[DECOMPILER] Hooking modules...')
	
	for catName, cat in pairs(shared.vape.Categories) do
		if cat.CreateModule then
			local old = cat.CreateModule
			cat.CreateModule = function(self, opt)
				if opt and opt.Name and table.find(targetModules, opt.Name) then
					warn('[DECOMPILER] Found target:', opt.Name)
					
					-- Декомпилируем Function
					if opt.Function then
						local ok, source = pcall(decompile, opt.Function)
						if ok and source and #source > 50 then
							local filename = string.format('%s/%s_main.lua', DUMP_FOLDER, 
								opt.Name:gsub('[^%w]', '_'))
							writefile(filename, source)
							warn('[DECOMPILER] Decompiled main function:', opt.Name)
							decompiled[opt.Name] = {main = true}
						else
							warn('[DECOMPILER] Failed to decompile:', opt.Name, source or 'no source')
						end
					end
					
					-- Декомпилируем все функции в Options
					if opt.Options then
						for optName, optData in pairs(opt.Options) do
							if type(optData) == 'table' and optData.Function then
								local ok, source = pcall(decompile, optData.Function)
								if ok and source and #source > 50 then
									local filename = string.format('%s/%s_%s.lua', DUMP_FOLDER,
										opt.Name:gsub('[^%w]', '_'),
										optName:gsub('[^%w]', '_'))
									writefile(filename, source)
									warn('[DECOMPILER] Decompiled option:', opt.Name, '->', optName)
									
									if not decompiled[opt.Name] then
										decompiled[opt.Name] = {}
									end
									decompiled[opt.Name][optName] = true
								end
							end
						end
					end
				end
				
				return old(self, opt)
			end
		end
	end
	
	warn('[DECOMPILER] Hooks installed!')
	
	-- Сохраняем результаты через 10 секунд
	task.wait(10)
	
	warn('[DECOMPILER] ===== DECOMPILATION COMPLETE =====')
	warn('[DECOMPILER] Decompiled modules:', #decompiled)
	
	for modName, funcs in pairs(decompiled) do
		local count = 0
		for _ in pairs(funcs) do count = count + 1 end
		warn('[DECOMPILER]   -', modName, ':', count, 'functions')
	end
	
	-- Сохраняем JSON
	local json = httpService:JSONEncode(decompiled)
	writefile(DUMP_FOLDER .. '/decompiled_summary.json', json)
	
	warn('[DECOMPILER] Files saved to:', DUMP_FOLDER)
	warn('[DECOMPILER] Check your executor workspace folder!')
end)

return decompiled
