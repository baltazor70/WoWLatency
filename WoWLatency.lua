-- Название аддона
local addonName = "WoWLatency"
local WoWLatency = CreateFrame("Frame", addonName, UIParent)

-- Переменные для хранения данных
local latencyData = {}
local lastUpdate = 0
local updateInterval = 5 -- Обновление каждые 5 секунд
local icon = nil

-- Информация о аддоне
local addonVersion = "1.0a"
local addonAuthor = "Baltazorius - Spineshatter (EU)"
local addonContact = "baltazor70@gmail.com"

-- Функция для обновления пинга
local function UpdateLatency()
    local _, _, homeLatency, worldLatency = GetNetStats()
    local currentTime = time()

    -- Сохраняем текущий пинг
    table.insert(latencyData, {
        time = currentTime,
        home = homeLatency,
        world = worldLatency
    })

    -- Удаляем старые данные (старше 30 минут)
    while #latencyData > 0 and latencyData[1].time < currentTime - 1800 do
        table.remove(latencyData, 1)
    end

    -- Обновляем текст на иконке
    if icon then
        -- Вычисляем средний пинг за последние 30 минут
        local totalHome, totalWorld = 0, 0
        for i, data in ipairs(latencyData) do
            totalHome = totalHome + data.home
            totalWorld = totalWorld + data.world
        end
        local avgHome = totalHome / #latencyData
        local avgWorld = totalWorld / #latencyData

        -- Отображаем текущий локальный пинг на иконке
        icon.text:SetText(homeLatency .. "ms")

        -- Обновляем подсказку
        icon:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
            GameTooltip:AddLine("WoWLatency")
            GameTooltip:AddLine("Current Ping:")
            GameTooltip:AddLine("Local: " .. homeLatency .. "ms")
            GameTooltip:AddLine("Server: " .. worldLatency .. "ms")
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Average ping for 30 min:")
            GameTooltip:AddLine("Local: " .. string.format("%.1f", avgHome) .. "ms")
            GameTooltip:AddLine("Server: " .. string.format("%.1f", avgWorld) .. "ms")
            GameTooltip:Show()
        end)
    end
end

-- Функция для создания иконки
local function CreateIcon()
    icon = CreateFrame("Button", nil, Minimap)
    icon:SetSize(20, 20)
    icon:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -35, -10)
    icon:SetNormalTexture("Interface\\Icons\\Spell_Nature_ElementalPrecision_1")
    icon:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Текст на иконке
    icon.text = icon:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    icon.text:SetPoint("CENTER", icon, "CENTER", 0, 0)
    icon.text:SetText("0ms")
end

-- Функция для отображения справки
local function ShowHelp()
    print("WoWLatency - Ping display addon")
    print("Ver.: " .. addonVersion)
    print("Dev and Autor: " .. addonAuthor)
    print("Contact: " .. addonContact)
end

-- Функция для приветственного сообщения
local function ShowWelcomeMessage()
    print("|cFF00FF00WoWLatency uploaded successfully!|r")
    print("|cFF00FF00Use the command |r|cFFFFFF00/wlhelp|r |cFF00FF00to get information about the addon.|r")
end

-- Инициализация аддона
local function InitializeAddon()
    -- Создание иконки
    CreateIcon()

    -- Запуск обновления пинга
    WoWLatency:SetScript("OnUpdate", function(self, elapsed)
        lastUpdate = lastUpdate + elapsed
        if lastUpdate >= updateInterval then
            UpdateLatency()
            lastUpdate = 0
        end
    end)

    -- Регистрация команды /wlhelp
    SLASH_WOWLATENCY1 = "/wlhelp"
    SlashCmdList["WOWLATENCY"] = ShowHelp

    -- Показ приветственного сообщения
    ShowWelcomeMessage()
end

-- Обработчик событий
WoWLatency:RegisterEvent("PLAYER_LOGIN")
WoWLatency:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        InitializeAddon()
    end
end)