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
local isTeleporting = false
local teleportCycle = false

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
toggleButton.Text = "Запуск цикла ТП"
toggleButton.TextScaled = true
toggleButton.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 180, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 50)
statusLabel.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
statusLabel.Text = "Цикл выключен"
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

-- Функция циклической телепортации
local function startTeleportCycle()
    if isTeleporting then return end
    
    teleportCycle = not teleportCycle
    
    if teleportCycle then
        toggleButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
        toggleButton.Text = "Остановить цикл ТП"
        statusLabel.Text = "Цикл активен"
        statusLabel.BackgroundColor3 = Color3.new(0, 0.5, 0)
        
        -- Запуск цикла телепортации
        spawn(function()
            local currentIndex = 1
            isTeleporting = true
            
            while teleportCycle and character and character:FindFirstChild("HumanoidRootPart") do
                -- Телепортация на текущую точку
                instantTeleport(teleportPoints[currentIndex])
                
                -- Обновление статуса
                statusLabel.Text = "Точка " .. currentIndex
                
                -- Ожидание 5 секунд
                for i = 5, 1, -1 do
                    if not teleportCycle then break end
                    statusLabel.Text = "Точка " .. currentIndex .. " (" .. i .. ")"
                    wait(1)
                end
                
                -- Переключение на следующую точку
                currentIndex = currentIndex % #teleportPoints + 1
            end
            
            isTeleporting = false
        end)
    else
        toggleButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.8)
        toggleButton.Text = "Запуск цикла ТП"
        statusLabel.Text = "Цикл выключен"
        statusLabel.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    end
end

-- Обработчик смены сервера
local function onServerSwitch()
    teleportCycle = false
    TeleportService:Teleport(game.PlaceId, player)
end

-- Подключение событий
toggleButton.MouseButton1Click:Connect(startTeleportCycle)
serverButton.MouseButton1Click:Connect(onServerSwitch)

-- Обработка нажатия клавиши T
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.T then
        startTeleportCycle()
    end
end)

-- Обновление персонажа при респавне
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
end)
