-- VapeTweaker Reinstaller with Premium Dump
-- Удаляет кэш и включает дампер

repeat task.wait() until game:IsLoaded()

-- Включаем дампер
getgenv().DumpPremium = true
getgenv().catrole = 'Premium'
getgenv().catname = 'Dumper'

warn('[Reinstall] Premium dumper enabled!')
warn('[Reinstall] Loading VapeTweaker...')

-- Загружаем VapeTweaker
loadstring(game:HttpGet('https://raw.githubusercontent.com/Freezewo/vapetweaker/main/init.lua', true))()

warn('[Reinstall] Check workspace/vapetweaker/dumps folder for results!')
warn('[Reinstall] Wait 15 seconds for dump to complete')
