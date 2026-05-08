-- Premium Module Dumper
-- Перехватывает регистрацию модулей и дампит их параметры

local DUMP_FILE = 'vapetweaker/profiles/premium_modules.json'
local httpService = game:GetService('HttpService')

local modules = {}
local oldCreateModule

-- Перехватываем создание модулей
task.spawn(function()
	repeat task.wait() until shared.vape
	local vape = shared.vape
	
	-- Ждём пока загрузится bedwars
	repeat task.wait() until vape.Categories and vape.Categories.Combat
	
	-- Перехватываем функцию создания модулей
	for categoryName, category in pairs(vape.Categories) do
		if category.CreateModule then
			local oldCreate = category.CreateModule
			category.CreateModule = function(self, options)
				-- Сохраняем информацию о модуле
				if options and options.Name then
					modules[options.Name] = {
						Name = options.Name,
						Category = categoryName,
						Tags = options.Tags or {},
						Tooltip = options.Tooltip or '',
						ExtraText = options.ExtraText or nil,
						Function = options.Function and 'exists' or 'none'
					}
					
					-- Если есть тег NEW - записываем
					if options.Tags and table.find(options.Tags, 'new') then
						warn('[PREMIUM] Found NEW module:', options.Name, 'in', categoryName)
					end
				end
				
				return oldCreate(self, options)
			end
		end
	end
	
	-- Через 10 секунд сохраняем всё что нашли
	task.wait(10)
	
	local json = httpService:JSONEncode(modules)
	writefile(DUMP_FILE, json)
	
	warn('[PREMIUM DUMPER] Saved', #modules, 'modules to', DUMP_FILE)
	
	-- Выводим модули с NEW тегом
	local newModules = {}
	for name, data in pairs(modules) do
		if data.Tags and table.find(data.Tags, 'new') then
			table.insert(newModules, name)
		end
	end
	
	if #newModules > 0 then
		warn('[PREMIUM] Modules with NEW tag:')
		for _, name in pairs(newModules) do
			warn('  -', name)
		end
	end
end)

return modules
