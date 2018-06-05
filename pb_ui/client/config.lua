Config = {}

-- Глобальное масштабирование интерфейса
-- При включении интерфейс отрисовывается в разрешении Config.scalingWidth, Config.scalingHeight
-- и масштабируется под разрешение экрана. Таким образом не нужно беспокоиться о масштабировании
-- элементов интерфейса в своём коде.
--
-- Scaling Mode: none - без масштабирования; fit_horizontal - масштабирование по горизонтальным размерам экрана; fit_vertical
Config.scalingMode    = "fit_horizontal"
-- Разрешение, ИЗ которого происходит масштабирование в разрешение пользователя
Config.scalingWidth   = 1920
Config.scalingHeight  = 1080
-- Способ масштабирования шрифтов:
-- scale_text - масштабирование на этапе отрисовки (создает размытие текста)
-- scale_font - масштабирование размера шрифтов при создании (чёткий текст, размеры могут не совпадать идеально)
Config.scalingFontsMode = "scale_text"

-- Настройки дебага
Config.debugMessages        = false -- Отображение дополнительных сообщений в debugscrip
Config.debugDrawBoxes       = false -- Отображение границ виджетов
Config.debugDrawNames       = false -- Отображение названий и ID виджетов
Config.debugDrawCalls       = false -- Отображение количества вызовов отрисовки за кадр
Config.debugDrawRenderTime  = false -- Отображение времени отрисовки кадра GUI

-- Команды для включения некоторых функций дебага
Config.debugCommandsEnabled = true

-- Запуск тестового интерфейса из test.lua
-- используется для проверки работы новых виджетов
Config.testModeEnabled = true

-- Шрифты
Config.defaultFont = "regular" -- Шрифт по умолчанию (используются только шрифты, загруженные в assets.lua)
Config.fontSizeExtraSmall = 6
Config.fontSizeSmall      = 9
Config.fontSizeDefault    = 12
Config.fontSizeLarge      = 16
Config.fontSizeExtraLarge = 20

-- Залипание клавиш
-- По умолчанию в МТА не реализовано залипание таких клавиш, как backspace и т. д.
Config.textInputRepeatWait  = 400 -- Время, после которого начинается повторение действия
Config.textInputRepeatDelay = 50  -- Задержка перед следующим повторением действия
