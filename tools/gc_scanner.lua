-- Garbage Collector Scanner
-- Сканирует GC и ищет функции связанные с premium модулями

local DUMP_FOLDER = 'vapetweaker/dumps/gc'

warn('[GC SCANNER] ===== STARTING GC SCAN =====')

-- Создаём папку
pcall(function()
	if not isfolder('vapetweaker') then makefolder('vapetweaker') end
	if not isfolder('vapetweaker/dumps') then makefolder('vapetweaker/dumps') end
	if not isfolder(DUMP_FOLDER) then makefolder(DUMP_FOLDER) end
	warn('[GC SCANNER] Folder created')
end)

if not decompile then
	warn('[GC SCANNER] ERROR: decompile not available!')
	return
end

-- Ключевые слова для поиска
local keywords = {
	'backtrack',
	'bedassist',
	'bed assist',
	'disabler',
	'fakelag',
	'fake lag',
	'owlaura',
	'owl aura',
	'autofarm',
	'premium',
	'new'
}

local function containsKeyword(str)
	str = str:lower()
	for _, keyword in pairs(keywords) do
		if str:find(keyword) then
			return keyword
		end
	end
	return nil
end

task.spawn(function()
	-- Ждём загрузки
	task.wait(5)
	
	warn('[GC SCANNER] Scanning garbage collector...')
	warn('[GC SCANNER] This may take a while...')
	
	local found = 0
	local scanned = 0
	local gc = getgc(true)
	
	for i, obj in pairs(gc) do
		scanned = scanned + 1
		
		pcall(function()
			if type(obj) == 'function' then
				local info = debug.getinfo(obj)
				
				-- Проверяем имя функции
				if info and info.name then
					local keyword = containsKeyword(info.name)
					if keyword then
						local ok, source = pcall(decompile, obj)
						if ok and source and #source > 100 then
							local filename = string.format('%s/func_%s_%d.lua', 
								DUMP_FOLDER, 
								keyword:gsub('[^%w]', '_'),
								found)
							writefile(filename, '-- Function: ' .. info.name .. '\n\n' .. source)
							warn('[GC SCANNER] Found:', info.name, '(keyword:', keyword .. ')')
							found = found + 1
						end
					end
				end
				
				-- Проверяем source
				if info and info.source then
					local keyword = containsKeyword(info.source)
					if keyword then
						local ok, source = pcall(decompile, obj)
						if ok and source and #source > 100 then
							-- Проверяем содержимое
							local contentKeyword = containsKeyword(source)
							if contentKeyword then
								local filename = string.format('%s/source_%s_%d.lua',
									DUMP_FOLDER,
									keyword:gsub('[^%w]', '_'),
									found)
								writefile(filename, '-- Source: ' .. info.source .. '\n\n' .. source)
								warn('[GC SCANNER] Found in source:', keyword)
								found = found + 1
							end
						end
					end
				end
			elseif type(obj) == 'table' then
				-- Ищем таблицы с интересными данными
				if obj.Name then
					local keyword = containsKeyword(tostring(obj.Name))
					if keyword then
						warn('[GC SCANNER] Found table:', obj.Name)
						
						-- Сохраняем таблицу
						local data = {}
						for k, v in pairs(obj) do
							if type(v) ~= 'function' and type(v) ~= 'userdata' then
								data[tostring(k)] = tostring(v)
							end
						end
						
						local httpService = game:GetService('HttpService')
						local json = httpService:JSONEncode(data)
						local filename = string.format('%s/table_%s.json',
							DUMP_FOLDER,
							keyword:gsub('[^%w]', '_'))
						writefile(filename, json)
					end
				end
			end
		end)
		
		-- Прогресс каждые 1000 объектов
		if scanned % 1000 == 0 then
			warn('[GC SCANNER] Progress:', scanned, '/', #gc, '- Found:', found)
			task.wait()
		end
	end
	
	warn('[GC SCANNER] ===== SCAN COMPLETE =====')
	warn('[GC SCANNER] Scanned:', scanned, 'objects')
	warn('[GC SCANNER] Found:', found, 'matches')
	warn('[GC SCANNER] Files saved to:', DUMP_FOLDER)
end)
