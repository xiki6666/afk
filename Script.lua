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
frame.Size = UDim2.new(0, 300, 0, 180) -- Увеличили высоту для кнопки
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Добавляем скругление углов
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- Создаем заголовок (для перетаскивания)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
title.Text = "Координаты камеры (T - обновить)"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Parent = frame

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

-- Добавляем кнопку для копирования
local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(0.9, 0, 0, 25)
copyButton.Position = UDim2.new(0.05, 0, 0, 140)
copyButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.5)
copyButton.Text = "Ctrl+C - Скопировать координаты"
copyButton.TextColor3 = Color3.new(1, 1, 1)
copyButton.TextScaled = true
copyButton.Parent = frame

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 5)
copyCorner.Parent = copyButton

-- Создаем невидимое TextBox для копирования текста
local copyTextBox = Instance.new("TextBox")
copyTextBox.Size = UDim2.new(0, 1, 0, 1)
copyTextBox.Position = UDim2.new(0, -10, 0, -10)
copyTextBox.BackgroundTransparency = 1
copyTextBox.TextTransparency = 1
copyTextBox.Text = ""
copyTextBox.Parent = frame

-- Переменные для перетаскивания
local dragging = false
local dragInput, dragStart, startPos

-- Текущие значения координат
local currentPosition = ""
local currentRotation = ""
local currentLookVector = ""

-- Функция обновления координат
local function updateCameraInfo()
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local position = camera.CFrame.Position
    local rotation = camera.CFrame - camera.CFrame.Position
    local lookVector = camera.CFrame.LookVector
    
    currentPosition = string.format("Позиция: X: %.2f, Y: %.2f, Z: %.2f", 
        position.X, position.Y, position.Z)
    positionLabel.Text = currentPosition
    
    -- Получаем углы Эйлера из CFrame
    local x, y, z = rotation:ToEulerAnglesXYZ()
    currentRotation = string.format("Поворот: X: %.2f, Y: %.2f, Z: %.2f", 
        math.deg(x), math.deg(y), math.deg(z))
    rotationLabel.Text = currentRotation
    
    currentLookVector = string.format("Направление: X: %.2f, Y: %.2f, Z: %.2f", 
        lookVector.X, lookVector.Y, lookVector.Z)
    lookVectorLabel.Text = currentLookVector
end

-- Функция для копирования координат в буфер обмена
local function copyToClipboard()
    local allText = currentPosition .. "\n" .. currentRotation .. "\n" .. currentLookVector
    
    -- Устанавливаем текст в TextBox
    copyTextBox.Text = allText
    -- Выделяем весь текст
    copyTextBox:CaptureFocus()
    copyTextBox.Text = allText -- Устанавливаем текст после получения фокуса
    wait() -- Ждем один кадр
    copyTextBox:SelectAll() -- Выделяем весь текст
    
    -- Визуальная обратная связь
    copyButton.BackgroundColor3 = Color3.new(0.2, 0.7, 0.2)
    copyButton.Text = "Координаты скопированы!"
    
    -- Возвращаем исходный вид через 1 секунду
    delay(1, function()
        copyButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.5)
        copyButton.Text = "Ctrl+C - Скопировать координаты"
    end)
end

-- Обработчик нажатия кнопки копирования
copyButton.MouseButton1Click:Connect(copyToClipboard)

-- Обработчик горячих клавиш
local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.T then
        updateCameraInfo()
    elseif input.KeyCode == Enum.KeyCode.C and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        copyToClipboard()
    elseif input.KeyCode == Enum.KeyCode.C and UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
        copyToClipboard()
    end
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

-- Подключаем обработчик горячих клавиш
UserInputService.InputBegan:Connect(onInputBegan)

-- Первоначальное обновление
updateCameraInfo()

print("GUI с координатами камеры создано!")
print("Нажмите T для обновления координат")
print("Нажмите Ctrl+C или кнопку для копирования координат")
print("Тащите за верхнюю панель для перемещения GUI")
