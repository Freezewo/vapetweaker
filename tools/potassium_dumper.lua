-- Potassium Advanced Dumper
-- Специально для Potassium executor с мощным decompile

local httpService = game:GetService('HttpService')
local DUMP_FOLDER = 'vapetweaker/dumps/potassium'

warn('[POTASSIUM] ===== ADVANCED DUMP STARTING =====')

-- Создаём папки
pcall(function()
	if not isfolder('vapetweaker') then makefolder('vapetweaker') end
	if not isfolder('vapetweaker/dumps') then makefolder('vapetweaker/dumps') end
	if not isfolder(DUMP_FOLDER) then makefolder(DUMP_FOLDER) end
	warn('[POTASSIUM] Folders created')
end)

-- Проверяем decompile
if not decompile then
	warn('[POTASSIUM] ERROR: decompile not found!')
	return
end

warn('[POTASSIUM] Decompile available!')

local decompiled = {}
local targetModules = {
	'BackTrack',
	'Bed Assist', 
	'Disabler',
	'Fake Lag',
	'Owl Aura',
	'Auto Farm Macro',
	'Trap Disabler'
}

-- Агрессивный перехват CreateModule
task.spawn(function()
	repeat task.wait(0.1) until shared.vape and shared.vape.Categories
	
	warn('[POTASSIUM] Vape loaded, installing aggressive hooks...')
	
	for catName, cat in pairs(shared.vape.Categories) do
		if cat.CreateModule then
			local old = cat.CreateModule
			cat.CreateModule = function(self, opt)
				pcall(function()
					if opt and opt.Name then
						warn('[POTASSIUM] Module detected:', opt.Name, 'in', catName)
						
						-- Декомпилируем MAIN функцию
						if opt.Function then
							warn('[POTASSIUM] Attempting to decompile main function...')
							local ok, source = pcall(decompile, opt.Function)
							if ok and source and #source > 50 then
								local filename = string.format('%s/%s_MAIN.lua', DUMP_FOLDER,
									opt.Name:gsub('[^%w]', '_'))
								writefile(filename, '-- Module: ' .. opt.Name .. '\n-- Category: ' .. catName .. '\n\n' .. source)
								warn('[POTASSIUM] ✓ Decompiled MAIN:', opt.Name)
								
								if not decompiled[opt.Name] then
									decompiled[opt.Name] = {}
								end
								decompiled[opt.Name].main = true
							else
								warn('[POTASSIUM] ✗ Failed main:', opt.Name, '-', tostring(source))
							end
						end
						
						-- Декомпилируем ВСЕ опции
						if opt.Options then
							warn('[POTASSIUM] Found', #opt.Options, 'options for', opt.Name)
							for optName, optData in pairs(opt.Options) do
								if type(optData) == 'table' then
									-- Декомпилируем Function
									if optData.Function then
										local ok, source = pcall(decompile, optData.Function)
										if ok and source and #source > 50 then
											local filename = string.format('%s/%s_OPT_%s.lua', DUMP_FOLDER,
												opt.Name:gsub('[^%w]', '_'),
												optName:gsub('[^%w]', '_'))
											writefile(filename, '-- Option: ' .. optName .. '\n-- Module: ' .. opt.Name .. '\n\n' .. source)
											warn('[POTASSIUM] ✓ Decompiled option:', opt.Name, '->', optName)
											
											if not decompiled[opt.Name] then
												decompiled[opt.Name] = {}
											end
											decompiled[opt.Name][optName] = true
										end
									end
									
									-- Декомпилируем Callback
									if optData.Callback then
										local ok, source = pcall(decompile, optData.Callback)
										if ok and source and #source > 50 then
											local filename = string.format('%s/%s_CALLBACK_%s.lua', DUMP_FOLDER,
												opt.Name:gsub('[^%w]', '_'),
												optName:gsub('[^%w]', '_'))
											writefile(filename, '-- Callback: ' .. optName .. '\n-- Module: ' .. opt.Name .. '\n\n' .. source)
											warn('[POTASSIUM] ✓ Decompiled callback:', opt.Name, '->', optName)
										end
									end
								end
							end
						end
						
						-- Сохраняем метаданные
						local metadata = {
							Name = opt.Name,
							Category = catName,
							Tags = opt.Tags or {},
							Tooltip = opt.Tooltip or '',
							ExtraText = opt.ExtraText or '',
							HasFunction = opt.Function and true or false,
							OptionsCount = opt.Options and #opt.Options or 0
						}
						
						local json = httpService:JSONEncode(metadata)
						local filename = string.format('%s/%s_metadata.json', DUMP_FOLDER,
							opt.Name:gsub('[^%w]', '_'))
						writefile(filename, json)
					end
				end)
				
				return old(self, opt)
			end
		end
	end
	
	warn('[POTASSIUM] Hooks installed!')
	
	-- Сохраняем сводку через 10 секунд
	task.wait(10)
	
	warn('[POTASSIUM] ===== DUMP COMPLETE =====')
	
	local summary = {
		decompiled = decompiled,
		timestamp = os.time(),
		executor = 'Potassium'
	}
	
	local json = httpService:JSONEncode(summary)
	writefile(DUMP_FOLDER .. '/summary.json', json)
	
	-- Статистика
	local totalFuncs = 0
	for modName, funcs in pairs(decompiled) do
		local count = 0
		for _ in pairs(funcs) do count = count + 1 end
		totalFuncs = totalFuncs + count
		warn('[POTASSIUM]', modName, ':', count, 'functions')
	end
	
	warn('[POTASSIUM] Total functions decompiled:', totalFuncs)
	warn('[POTASSIUM] Files saved to:', DUMP_FOLDER)
end)

-- Дополнительный GC сканер для Potassium
task.spawn(function()
	task.wait(5)
	warn('[POTASSIUM] Starting GC scan...')
	
	local gcCount = 0
	local gc = getgc(true)
	
	for i, obj in pairs(gc) do
		pcall(function()
			if type(obj) == 'function' then
				local info = debug.getinfo(obj)
				if info and info.name then
					-- Ищем функции с нужными именами
					for _, target in pairs(targetModules) do
						if info.name:lower():find(target:lower():gsub(' ', '')) then
							local ok, source = pcall(decompile, obj)
							if ok and source and #source > 100 then
								local filename = string.format('%s/GC_%s_%d.lua', DUMP_FOLDER,
									target:gsub('[^%w]', '_'),
									gcCount)
								writefile(filename, '-- GC Function: ' .. info.name .. '\n\n' .. source)
								warn('[POTASSIUM] ✓ GC found:', info.name)
								gcCount = gcCount + 1
							end
						end
					end
				end
			end
		end)
		
		if i % 5000 == 0 then
			task.wait()
		end
	end
	
	warn('[POTASSIUM] GC scan complete:', gcCount, 'functions found')
end)

return decompiled
