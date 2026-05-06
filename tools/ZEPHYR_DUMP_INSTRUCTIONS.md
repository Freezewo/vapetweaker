# Zephyr Dumper - Инструкция

Этот скрипт логирует ВСЕ вызовы связанные с abilities/cooldowns чтобы понять как работает эксплоит конкурента.

## Как использовать:

### Шаг 1: Запусти дампер
```lua
loadstring(readfile("tools/zephyr_dumper.lua"))()
```

Или если через HTTP:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Freezewo/vapetweaker/main/tools/zephyr_dumper.lua"))()
```

### Шаг 2: Дождись сообщения
Должно появиться:
- `[INIT] === ALL HOOKS INSTALLED ===`
- `[INIT] Now load competitor's script and use their Zephyr exploit`

### Шаг 3: Загрузи скрипт конкурента
Запусти их скрипт как обычно

### Шаг 4: Используй их Zephyr эксплоит
Включи их функцию для Zephyr и используй способность

### Шаг 5: Смотри логи
Все вызовы будут логироваться в:
- Консоль (F9)
- Уведомления (если vape загружен)

### Шаг 6: Сохрани лог
В консоли выполни:
```lua
_G.dumpZephyrLog()
```

Это выведет весь лог. Скопируй его и отправь мне!

## Что логируется:

- ✅ Все методы CooldownController
- ✅ Все методы AbilityController  
- ✅ Все вызовы Client:Get (remotes)
- ✅ Все SendToServer/CallServer
- ✅ Все SetAttribute на персонаже
- ✅ Все параметры вызовов

## Пример лога:

```
[1] [INIT] === ZEPHYR DUMPER STARTED ===
[2] [HOOK] Hooking CooldownController methods...
[3] [METHOD] CooldownController.setOnCooldown
[4] [CALL] CooldownController:setOnCooldown(self, wind_walker_jump, 0, false)
[5] [REMOTE] Client:Get('SomeRemote')
[6] [SEND] SomeRemote:SendToServer(table)
```

Это покажет ТОЧНО что делает их эксплоит! 🔥
