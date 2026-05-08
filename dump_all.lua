-- Dump All Premium Content
-- Запускает все дамперы одновременно

warn('===== VAPETWEAKER PREMIUM DUMPER =====')
warn('Loading VapeTweaker with all dumpers enabled...')

-- Включаем все дамперы
getgenv().DumpPremium = true
getgenv().catrole = 'Premium'
getgenv().catname = 'Dumper'

-- Загружаем VapeTweaker
loadstring(game:HttpGet('https://raw.githubusercontent.com/Freezewo/vapetweaker/main/init.lua'))()

-- Ждём загрузки
task.wait(3)

warn('===== STARTING ADDITIONAL DUMPERS =====')

-- Запускаем декомпилятор
pcall(function()
	loadstring(game:HttpGet('https://raw.githubusercontent.com/Freezewo/vapetweaker/main/tools/decompile_premium.lua'))()
	warn('[DUMP ALL] Decompiler started')
end)

-- Запускаем GC сканер
task.wait(2)
pcall(function()
	loadstring(game:HttpGet('https://raw.githubusercontent.com/Freezewo/vapetweaker/main/tools/gc_scanner.lua'))()
	warn('[DUMP ALL] GC Scanner started')
end)

warn('===== ALL DUMPERS RUNNING =====')
warn('Wait 15-20 seconds for completion')
warn('Check: workspace/vapetweaker/dumps/')
warn('  - dumps/premium_raw.lua (raw premium code)')
warn('  - dumps/modules.json (module list)')
warn('  - dumps/decompiled/ (decompiled functions)')
warn('  - dumps/gc/ (garbage collector finds)')
