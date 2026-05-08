# Как дампнуть Premium модули

## Метод 1: Автоматический дамп (рекомендуется)

1. Запусти скрипт с включенным дампером:
```lua
getgenv().DumpPremium = true
loadstring(game:HttpGet('https://raw.githubusercontent.com/Freezewo/vapetweaker/main/init.lua'))()
```

2. Подожди 15 секунд

3. Проверь папку `workspace/vapetweaker/dumps/`:
   - `premium_raw_*.lua` - сырой код premium.luau
   - `module_*.lua` - декомпилированные модули
   - `gc_premium_*.lua` - функции из garbage collector
   - `summary.json` - сводка всех найденных модулей

## Метод 2: Ручной дамп через консоль

1. Загрузи VapeTweaker
2. Открой консоль (F9)
3. Выполни команды:

```lua
-- Дамп garbage collector
shared.GCDump('bedassist')
shared.GCDump('backtrack')
shared.GCDump('disabler')
shared.GCDump('fakelag')

-- Сканирование shared таблиц
shared.ScanShared()

-- Поиск URL в дампах
shared.FindURLs()
```

## Метод 3: Перехват loadstring

Дампер уже перехватывает все вызовы loadstring. Если premium.luau использует loadstring, код будет сохранён автоматически.

## Что искать в дампах

Модули с NEW тегом:
- BedAssist
- BackTrack  
- Disabler
- FakeLag

Ищи в дампах:
- `Tags = {'new'}` или `Tags = {"new"}`
- `Name = 'BedAssist'` и т.д.
- Функции с этими именами

## Troubleshooting

Если дампы пустые:
1. Убедись что у твоего экзекутора есть `decompile` функция
2. Попробуй другой экзекутор (Synapse X, Script-Ware, etc)
3. Premium может быть защищён от декомпиляции

Если premium не загружается:
1. Проверь что файл `games/bedwars/premium.luau` не пустой
2. Убедись что `catrole = 'Premium'` установлен
3. Проверь консоль на ошибки

## После дампа

1. Найди модули с NEW тегом в дампах
2. Удали строки `Tags = {'new'}` из кода
3. Замени `games/bedwars/premium.luau` на очищенную версию
4. Или перенеси модули в `games/bedwars/main.luau`
