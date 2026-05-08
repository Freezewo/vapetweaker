-- Advanced Premium Dumper - SIMPLIFIED
-- Перехватывает модули и сохраняет их

local httpService = game:GetService('HttpService')
local DUMP_FOLDER = 'vapetweaker/dumps'

warn('[DUMPER] ===== STARTING PREMIUM DUMP =====')

-- Создаём папку
pcall(function()
	if not isfolder('vapetweaker') then makefolder('vapetweaker') end
	if not isfolder(DUMP_FOLDER) then makefolder(DUMP_FOLDER) end
	warn('[DUMPER] Folder created:', DUMP_FOLDER)
end)

local captured = {
	modules = {},
	timestamp = os.time()
}

-- Перехватываем loadstring
local oldLoadstring = loadstring
getgenv().loadstring = function(source, chunkname, ...)
	pcall(function()
		if type(source) == 'string' and #source > 100 then
			local tag = tostring(chunkname or 'unknown')
			warn('[DUMPER] Loadstring called:', tag, 'size:', #source)
			
			-- Если это premium
			if tag:find('paid') or tag:find('premium') then
				warn('[DUMPER] !!! PREMIUM LOADSTRING CAUGHT !!!')
				local filename = string.format('%s/premium_raw.lua', DUMP_FOLDER)
				writefile(filename, source)
				warn('[DUMPER] Saved to:', filename)
			end
		end
	end)
	
	return oldLoadstring(source, chunkname, ...)
end

warn('[DUMPER] Loadstring hook installed')

-- Перехватываем CreateModule
task.spawn(function()
	repeat task.wait(0.5) until shared.vape
	local vape = shared.vape
	
	warn('[DUMPER] Vape found, waiting for categories...')
	repeat task.wait(0.5) until vape.Categories
	
	warn('[DUMPER] Categories loaded, hooking...')
	
	for categoryName, category in pairs(vape.Categories) do
		if category.CreateModule then
			local oldCreate = category.CreateModule
			category.CreateModule = function(self, options)
				pcall(function()
					if options and options.Name then
						warn('[DUMPER] Module created:', options.Name, 'in', categoryName)
						
						local moduleData = {
							Name = options.Name,
							Category = categoryName,
							Tags = options.Tags or {},
							Tooltip = options.Tooltip or '',
						}
						
						captured.modules[options.Name] = moduleData
						
						-- Если есть NEW тег
						if options.Tags and table.find(options.Tags, 'new') then
							warn('[DUMPER] !!! NEW MODULE FOUND:', options.Name, '!!!')
						end
						
						-- Пытаемся декомпилировать
						if options.Function and decompile then
							local ok, source = pcall(decompile, options.Function)
							if ok and source and #source > 50 then
								local filename = string.format('%s/module_%s.lua', DUMP_FOLDER, 
									options.Name:gsub('[^%w]', '_'))
								writefile(filename, source)
								warn('[DUMPER] Decompiled:', options.Name)
							end
						end
					end
				end)
				
				return oldCreate(self, options)
			end
		end
	end
	
	warn('[DUMPER] All categories hooked!')
	
	-- Сохраняем через 10 секунд
	task.wait(10)
	
	warn('[DUMPER] ===== SAVING RESULTS =====')
	
	local json = httpService:JSONEncode(captured)
	writefile(DUMP_FOLDER .. '/modules.json', json)
	
	warn('[DUMPER] Total modules:', #captured.modules)
	warn('[DUMPER] Saved to:', DUMP_FOLDER .. '/modules.json')
	
	-- Список модулей с NEW
	local newMods = {}
	for name, data in pairs(captured.modules) do
		if data.Tags and table.find(data.Tags, 'new') then
			table.insert(newMods, name)
		end
	end
	
	if #newMods > 0 then
		warn('[DUMPER] === MODULES WITH NEW TAG ===')
		for _, name in pairs(newMods) do
			warn('[DUMPER]   - ' .. name)
		end
	else
		warn('[DUMPER] No modules with NEW tag found')
	end
	
	warn('[DUMPER] ===== DUMP COMPLETE =====')
end)

return captured
