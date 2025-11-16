-- LocalScript в StarterPlayerScripts или StarterGui
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Создаем GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CameraInfoGUI"
screenGui.Parent = playerGui

-- Создаем основной фрейм
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Создаем заголовок (будет использоваться для перетаскивания)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
title.Text = "Координаты камеры (Нажми T) - Тащи за эту панель"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Parent = frame

-- Добавляем скругление углов для красоты
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

-- Создаем текстовые поля для координат
local positionLabel = Instance.new("TextLabel")
positionLabel.Size = UDim2.new(1, -10, 0, 30)
positionLabel.Position = UDim2.new(0, 5, 0, 35)
positionLabel.BackgroundTransparency = 1
positionLabel.Text = "Позиция: X: 0, Y: 0, Z: 0"
positionLabel.TextColor3 = Color3.new(1, 1, 1)
positionLabel.TextXAlignment = Enum.TextXAlignment.Left
positionLabel.TextScaled = true
positionLabel.Parent = frame

local rotationLabel = Instance.new("TextLabel")
rotationLabel.Size = UDim2.new(1, -10, 0, 30)
rotationLabel.Position = UDim2.new(0, 5, 0, 70)
rotationLabel.BackgroundTransparency = 1
rotationLabel.Text = "Поворот: X: 0, Y: 0, Z: 0"
rotationLabel.TextColor3 = Color3.new(1, 1, 1)
rotationLabel.TextXAlignment = Enum.TextXAlignment.Left
rotationLabel.TextScaled = true
rotationLabel.Parent = frame

local lookVectorLabel = Instance.new("TextLabel")
lookVectorLabel.Size = UDim2.new(1, -10, 0, 30)
lookVectorLabel.Position = UDim2.new(0, 5, 0, 105)
lookVectorLabel.BackgroundTransparency = 1
lookVectorLabel.Text = "Направление: X: 0, Y: 0, Z: 0"
lookVectorLabel.TextColor3 = Color3.new(1, 1, 1)
lookVectorLabel.TextXAlignment = Enum.TextXAlignment.Left
lookVectorLabel.TextScaled = true
lookVectorLabel.Parent = frame

-- Переменные для перетаскивания
local dragging = false
local dragInput, dragStart, startPos

-- Функция обновления координат
local function updateCameraInfo()
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local position = camera.CFrame.Position
    local rotation = camera.CFrame - camera.CFrame.Position
    local lookVector = camera.CFrame.LookVector
    
    positionLabel.Text = string.format("Позиция: X: %.2f, Y: %.2f, Z: %.2f", 
        position.X, position.Y, position.Z)
    
    -- Получаем углы Эйлера из CFrame
    local x, y, z = rotation:ToEulerAnglesXYZ()
    rotationLabel.Text = string.format("Поворот: X: %.2f, Y: %.2f, Z: %.2f", 
        math.deg(x), math.deg(y), math.deg(z))
    
    lookVectorLabel.Text = string.format("Направление: X: %.2f, Y: %.2f, Z: %.2f", 
        lookVector.X, lookVector.Y, lookVector.Z)
end

-- Функции для перетаскивания
local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        
        -- Легкий эффект при захвате
        local tween = TweenService:Create(title, TweenInfo.new(0.1), {BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)})
        tween:Play()
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                -- Возвращаем цвет
                local tween = TweenService:Create(title, TweenInfo.new(0.1), {BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)})
                tween:Play()
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Обработчик нажатия клавиши T
local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.T then
        updateCameraInfo()
    end
end

-- Подключаем обработчик
UserInputService.InputBegan:Connect(onInputBegan)

-- Первоначальное обновление
updateCameraInfo()

print("GUI с координатами камеры создано! Нажмите T для обновления. Тащите за верхнюю панель для перемещения.")
