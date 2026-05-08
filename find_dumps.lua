-- Скрипт для поиска папки dumps
-- Запусти это в консоли после загрузки VapeTweaker

local function findDumps()
	warn('===== SEARCHING FOR DUMPS FOLDER =====')
	
	-- Проверяем разные пути
	local paths = {
		'vapetweaker/dumps',
		'workspace/vapetweaker/dumps',
		'./vapetweaker/dumps',
	}
	
	for _, path in pairs(paths) do
		if isfolder(path) then
			warn('[FOUND] Folder exists at: ' .. path)
			
			-- Показываем файлы
			local files = listfiles(path)
			if #files > 0 then
				warn('[FILES] Found ' .. #files .. ' files:')
				for _, file in pairs(files) do
					warn('  - ' .. file)
				end
			else
				warn('[EMPTY] Folder is empty')
			end
		else
			warn('[NOT FOUND] ' .. path)
		end
	end
	
	-- Создаём тестовый файл
	local testPath = 'vapetweaker/dumps/test.txt'
	writefile(testPath, 'Test file created at: ' .. os.date())
	warn('[TEST] Created test file at: ' .. testPath)
	warn('[INFO] Check your executor folder for "workspace" or "bin" folder')
	warn('[INFO] Common locations:')
	warn('  - Solara: C:\\Users\\YourName\\AppData\\Local\\Solara\\workspace')
	warn('  - Wave: C:\\Users\\YourName\\AppData\\Local\\Wave\\workspace')
	warn('  - Synapse: Synapse\\workspace')
	
	-- Пытаемся найти через listfiles
	warn('[SEARCHING] Scanning all files...')
	local allFiles = listfiles('vapetweaker')
	for _, file in pairs(allFiles) do
		if file:find('dump') then
			warn('[FOUND FILE] ' .. file)
		end
	end
	
	warn('===== SEARCH COMPLETE =====')
end

findDumps()
