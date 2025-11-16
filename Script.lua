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
frame.Size = UDim2.new(0, 320, 0, 180)
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

-- Создаем метки для координат
local positionText = Instance.new("TextLabel")
positionText.Size = UDim2.new(0, 70, 0, 30)
positionText.Position = UDim2.new(0, 5, 0, 35)
positionText.BackgroundTransparency = 1
positionText.Text = "Позиция:"
positionText.TextColor3 = Color3.new(1, 1, 1)
positionText.TextXAlignment = Enum.TextXAlignment.Left
positionText.TextScaled = true
positionText.Parent = frame

local rotationText = Instance.new("TextLabel")
rotationText.Size = UDim2.new(0, 70, 0, 30)
rotationText.Position = UDim2.new(0, 5, 0, 70)
rotationText.BackgroundTransparency = 1
rotationText.Text = "Поворот:"
positionText.TextColor3 = Color3.new(1, 1, 1)
rotationText.TextXAlignment = Enum.TextXAlignment.Left
rotationText.TextScaled = true
rotationText.Parent = frame

local lookVectorText = Instance.new("TextLabel")
lookVectorText.Size = UDim2.new(0, 85, 0, 30)
lookVectorText.Position = UDim2.new(0, 5, 0, 105)
lookVectorText.BackgroundTransparency = 1
lookVectorText.Text = "Направление:"
positionText.TextColor3 = Color3.new(1, 1, 1)
lookVectorText.TextXAlignment = Enum.TextXAlignment.Left
lookVectorText.TextScaled = true
lookVectorText.Parent = frame

-- Создаем TextBox для координат (можно выделять и копировать)
local positionBox = Instance.new("TextBox")
positionBox.Size = UDim2.new(0, 235, 0, 30)
positionBox.Position = UDim2.new(0, 75, 0, 35)
positionBox.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
positionBox.BackgroundTransparency = 0.5
positionBox.Text = "X: 0, Y: 0, Z: 0"
positionBox.TextColor3 = Color3.new(1, 1, 1)
positionBox.TextXAlignment = Enum.TextXAlignment.Left
positionBox.TextScaled = true
positionBox.ClearTextOnFocus = false
positionBox.Parent = frame

local rotationBox = Instance.new("TextBox")
rotationBox.Size = UDim2.new(0, 235, 0, 30)
rotationBox.Position = UDim2.new(0, 75, 0, 70)
rotationBox.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
rotationBox.BackgroundTransparency = 0.5
rotationBox.Text = "X: 0, Y: 0, Z: 0"
rotationBox.TextColor3 = Color3.new(1, 1, 1)
rotationBox.TextXAlignment = Enum.TextXAlignment.Left
rotationBox.TextScaled = true
rotationBox.ClearTextOnFocus = false
rotationBox.Parent = frame

local lookVectorBox = Instance.new("TextBox")
lookVectorBox.Size = UDim2.new(0, 235, 0, 30)
lookVectorBox.Position = UDim2.new(0, 90, 0, 105)
lookVectorBox.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
lookVectorBox.BackgroundTransparency = 0.5
lookVectorBox.Text = "X: 0, Y: 0, Z: 0"
lookVectorBox.TextColor3 = Color3.new(1, 1, 1)
lookVectorBox.TextXAlignment = Enum.TextXAlignment.Left
lookVectorBox.TextScaled = true
lookVectorBox.ClearTextOnFocus = false
lookVectorBox.Parent = frame

-- Добавляем скругления для TextBox
local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 5)
boxCorner.Parent = positionBox
boxCorner:Clone().Parent = rotationBox
boxCorner:Clone().Parent = lookVectorBox

-- Добавляем кнопку для копирования всех координат
local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(0.9, 0, 0, 25)
copyButton.Position = UDim2.new(0.05, 0, 0, 140)
copyButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.5)
copyButton.Text = "Ctrl+C - Скопировать все координаты"
copyButton.TextColor3 = Color3.new(1, 1, 1)
copyButton.TextScaled = true
copyButton.Parent = frame

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 5)
copyCorner.Parent = copyButton

-- Создаем невидимое TextBox для копирования всех координат
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
    
    currentPosition = string.format("X: %.2f, Y: %.2f, Z: %.2f", 
        position.X, position.Y, position.Z)
    positionBox.Text = currentPosition
    
    -- Получаем углы Эйлера из CFrame
    local x, y, z = rotation:ToEulerAnglesXYZ()
    currentRotation = string.format("X: %.2f, Y: %.2f, Z: %.2f", 
        math.deg(x), math.deg(y), math.deg(z))
    rotationBox.Text = currentRotation
    
    currentLookVector = string.format("X: %.2f, Y: %.2f, Z: %.2f", 
        lookVector.X, lookVector.Y, lookVector.Z)
    lookVectorBox.Text = currentLookVector
end

-- Функция для копирования всех координат в буфер обмена
local function copyAllToClipboard()
    local allText = "Позиция: " .. currentPosition .. "\nПоворот: " .. currentRotation .. "\nНаправление: " .. currentLookVector
    
    -- Устанавливаем текст в TextBox
    copyTextBox.Text = allText
    -- Выделяем весь текст
    copyTextBox:CaptureFocus()
    copyTextBox.Text = allText -- Устанавливаем текст после получения фокуса
    wait() -- Ждем один кадр
    copyTextBox:SelectAll() -- Выделяем весь текст
    
    -- Визуальная обратная связь
    copyButton.BackgroundColor3 = Color3.new(0.2, 0.7, 0.2)
    copyButton.Text = "Все координаты скопированы!"
    
    -- Возвращаем исходный вид через 1 секунду
    delay(1, function()
        copyButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.5)
        copyButton.Text = "Ctrl+C - Скопировать все координаты"
    end)
end

-- Обработчик нажатия кнопки копирования
copyButton.MouseButton1Click:Connect(copyAllToClipboard)

-- Обработчик горячих клавиш
local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.T then
        updateCameraInfo()
    elseif input.KeyCode == Enum.KeyCode.C and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
        copyAllToClipboard()
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

-- Функция для выделения всего текста при клике на TextBox
local function selectAllText(box)
    box.Focused:Connect(function()
        wait() -- Ждем один кадр
        box:SelectAll()
    end)
end

selectAllText(positionBox)
selectAllText(rotationBox)
selectAllText(lookVectorBox)

-- Первоначальное обновление
updateCameraInfo()

print("GUI с координатами камеры создано!")
print("Нажмите T для обновления координат")
print("Нажмите Ctrl+C или кнопку для копирования всех координат")
print("Кликайте на отдельные поля координат, чтобы выделить и скопировать их")
print("Тащите за верхнюю панель для перемещения GUI")
