local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Настройки телепортации
local teleportPoints = {
	Vector3.new(109.15, 3.74, 529.22),
	Vector3.new(170.43, 3.67, 474.95)
}
local currentTeleportIndex = 1
local teleportDuration = 1 -- Длительность твина в секундах

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
toggleButton.Text = "Телепорт (T)"
toggleButton.TextScaled = true
toggleButton.Parent = frame

local serverButton = Instance.new("TextButton")
serverButton.Size = UDim2.new(0, 180, 0, 40)
serverButton.Position = UDim2.new(0, 10, 0, 60)
serverButton.BackgroundColor3 = Color3.new(0.8, 0.4, 0.4)
serverButton.Text = "Другой сервер"
serverButton.TextScaled = true
serverButton.Parent = frame

-- Функция плавной телепортации
local function smoothTeleport(targetPosition)
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end

	local rootPart = character.HumanoidRootPart
	local tweenInfo = TweenInfo.new(
		teleportDuration,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = CFrame.new(targetPosition)})
	humanoid.PlatformStand = true
	tween:Play()
	tween.Completed:Wait()
	humanoid.PlatformStand = false
end

-- Обработчик переключения телепорта
local function onToggleTeleport()
	currentTeleportIndex = currentTeleportIndex % #teleportPoints + 1
	smoothTeleport(teleportPoints[currentTeleportIndex])
end

-- Обработчик смены сервера
local function onServerSwitch()
	TeleportService:Teleport(game.PlaceId, player)
end

-- Подключение событий
toggleButton.MouseButton1Click:Connect(onToggleTeleport)
serverButton.MouseButton1Click:Connect(onServerSwitch)

-- Обработка нажатия клавиши T
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.T then
		onToggleTeleport()
	end
end)

-- Обновление персонажа при респавне
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = newCharacter:WaitForChild("Humanoid")
end)
