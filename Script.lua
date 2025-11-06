local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Настройки телепортации
local teleportPoints = {
    Vector3.new(172.26, 47.47, 426.68),
    Vector3.new(170.43, 3.66, 474.95)
}
local currentTeleportIndex = 1

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGui"
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
frame.Parent = screenGui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 180, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.8)
toggleButton.Text = "Точка 1 (T)"
toggleButton.TextScaled = true
toggleButton.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 180, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 50)
statusLabel.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
statusLabel.Text = "Готова к телепортации"
statusLabel.TextScaled = true
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Parent = frame

local serverButton = Instance.new("TextButton")
serverButton.Size = UDim2.new(0, 180, 0, 40)
serverButton.Position = UDim2.new(0, 10, 0, 80)
serverButton.BackgroundColor3 = Color3.new(0.8, 0.4, 0.4)
serverButton.Text = "Другой сервер"
serverButton.TextScaled = true
serverButton.Parent = frame

-- Функция моментальной телепортации
local function instantTeleport(targetPosition)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    rootPart.CFrame = CFrame.new(targetPosition)
end

-- Функция обновления интерфейса
local function updateUI()
    toggleButton.Text = "Точка " .. currentTeleportIndex .. " (T)"
    statusLabel.Text = "Телепорт на точку " .. currentTeleportIndex
end

-- Обработчик телепортации
local function onTeleport()
    instantTeleport(teleportPoints[currentTeleportIndex])
    
    -- Мигающий эффект для обратной связи
    toggleButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
    statusLabel.BackgroundColor3 = Color3.new(0, 0.5, 0)
    
    -- Переключение на следующую точку
    currentTeleportIndex = currentTeleportIndex % #teleportPoints + 1
    
    -- Обновление интерфейса
    updateUI()
    
    -- Возврат к обычному цвету через 0.3 секунды
    delay(0.3, function()
        toggleButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.8)
        statusLabel.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        statusLabel.Text = "Готова к телепортации"
    end)
end

-- Обработчик смены сервера
local function onServerSwitch()
    TeleportService:Teleport(game.PlaceId, player)
end

-- Подключение событий
toggleButton.MouseButton1Click:Connect(onTeleport)
serverButton.MouseButton1Click:Connect(onServerSwitch)

-- Обработка нажатия клавиши T
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.T then
        onTeleport()
    end
end)

-- Обновление персонажа при респавне
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
end)

-- Инициализация интерфейса
updateUI()
