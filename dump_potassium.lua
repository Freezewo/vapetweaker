-- Potassium Premium Dumper
-- Специально оптимизирован для Potassium executor

warn('===== POTASSIUM PREMIUM DUMPER =====')
warn('Executor:', identifyexecutor and identifyexecutor() or 'Unknown')

-- Проверяем что это Potassium
if identifyexecutor then
	local exec = identifyexecutor()
	if exec ~= 'Potassium' then
		warn('[WARNING] This dumper is optimized for Potassium!')
		warn('[WARNING] Your executor:', exec)
		warn('[WARNING] Results may vary')
	else
		warn('[POTASSIUM] Detected! Using optimized dumper')
	end
end

-- Проверяем decompile
if not decompile then
	error('[ERROR] Your executor does not support decompile!')
end

warn('[OK] Decompile available')

-- Включаем дампер
getgenv().DumpPremium = true
getgenv().catrole = 'Premium'
getgenv().catname = 'Potassium Dumper'

-- Загружаем VapeTweaker
warn('[LOADING] VapeTweaker...')
loadstring(game:HttpGet('https://raw.githubusercontent.com/Freezewo/vapetweaker/main/init.lua'))()

-- Ждём загрузки
task.wait(2)

-- Запускаем Potassium дампер
warn('[LOADING] Potassium dumper...')
loadstring(game:HttpGet('https://raw.githubusercontent.com/Freezewo/vapetweaker/main/tools/potassium_dumper.lua'))()

warn('===== DUMPER STARTED =====')
warn('Wait 15 seconds for completion')
warn('Files will be saved to: workspace/vapetweaker/dumps/potassium/')
warn('')
warn('What will be dumped:')
warn('  - Main functions of all modules')
warn('  - All module options and callbacks')
warn('  - Metadata (Name, Tags, Tooltip)')
warn('  - GC scan results')
warn('')
warn('Target modules:')
warn('  - BackTrack')
warn('  - Bed Assist')
warn('  - Disabler')
warn('  - Fake Lag')
warn('  - Owl Aura')
warn('  - Auto Farm Macro')
