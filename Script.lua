-- Основная функция для безопасного выполнения
local function safeExecute()
	-- Проверяем, что мы в игре и есть локальный игрок
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	local player = game.Players.LocalPlayer
	if not player then
		repeat wait() until game.Players.LocalPlayer
		player = game.Players.LocalPlayer
	end

	-- Ждем пока появится PlayerGui
	local playerGui = player:WaitForChild("PlayerGui")

	-- Создаем объекты
	local screenGui = Instance.new("ScreenGui")
	local frame = Instance.new("Frame")
	local toggleButton = Instance.new("TextButton")

	-- Основные элементы
	local flyButton = Instance.new("TextButton")
	local speedInput = Instance.new("TextBox")
	local speedhackInput = Instance.new("TextBox")
	local speedhackButton = Instance.new("TextButton")
	local keybindButton = Instance.new("TextButton")
	local flyKeybindButton = Instance.new("TextButton")
	local teleportButton = Instance.new("TextButton")
	local teleportKeybindButton = Instance.new("TextButton")
	local proximityPromptButton = Instance.new("TextButton")
	local proximityKeybindButton = Instance.new("TextButton")
	local proximityRadarButton = Instance.new("TextButton")
	local radarDistanceInput = Instance.new("TextBox")
	local titleLabel = Instance.new("TextLabel")

	-- Переменные для управления
	local flying = false
	local speed = 50
	local speedhackSpeed = 33
	local speedhackEnabled = false
	local flyConnection = nil
	local bodyVelocity = nil
	local bodyGyro = nil
	local menuVisible = true
	local speedhackKey = Enum.KeyCode.R
	local flyKey = Enum.KeyCode.G
	local teleportKey = Enum.KeyCode.T
	local proximityKey = Enum.KeyCode.J
	local keybindListening = false
	local flyKeybindListening = false
	local teleportKeybindListening = false
	local proximityKeybindListening = false
	local teleportToggle = false

	-- Переменные для ProximityPrompt
	local proximityPromptEnabled = false
	local originalDurations = {}
	local radarEnabled = false
	local originalDistances = {}
	local radarDistance = 500

	-- Функция для безопасного получения персонажа
	local function getCharacter()
		local character = player.Character
		if not character then
			player.CharacterAdded:Wait()
			character = player.Character
		end
		return character
	end

	-- Функция для безопасного получения Humanoid
	local function getHumanoid(character)
		if not character then return nil end
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid then
			character.ChildAdded:Wait()
			humanoid = character:WaitForChild("Humanoid")
		end
		return humanoid
	end

	-- Функция для безопасного получения HumanoidRootPart
	local function getHumanoidRootPart(character)
		if not character then return nil end
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then
			character.ChildAdded:Wait()
			humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		end
		return humanoidRootPart
	end

	-- Настройка ScreenGui
	screenGui.Name = "MenuGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- Настройка фрейма (меню)
	frame.Size = UDim2.new(0, 400, 0, 520)
	frame.Position = UDim2.new(0.5, -200, 0.5, -250)
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	frame.BackgroundTransparency = 0.2
	frame.BorderColor3 = Color3.fromRGB(0, 170, 255)
	frame.BorderSizePixel = 2
	frame.Active = true
	frame.Draggable = true
	frame.Parent = screenGui

	-- Закругляем углы фрейма
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	-- Настройка кнопки сворачивания
	toggleButton.Size = UDim2.new(0, 150, 0, 30)
	toggleButton.Position = UDim2.new(0.5, -75, 0, -60)
	toggleButton.Text = "Toggle Menu"
	toggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	toggleButton.BorderColor3 = Color3.fromRGB(0, 170, 255)
	toggleButton.BorderSizePixel = 2
	toggleButton.Parent = screenGui

	-- Функция для стилизации кнопок
	local function styleButton(button, text, position)
		if not button then return end
		button.Size = UDim2.new(0, 380, 0, 30)
		button.Position = position
		button.Text = text
		button.TextScaled = true
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		button.BorderColor3 = Color3.fromRGB(0, 170, 255)
		button.BorderSizePixel = 2
		button.Parent = frame
	end

	-- Функция для стилизации полей ввода
	local function styleTextBox(textBox, text, position)
		if not textBox then return end
		textBox.Size = UDim2.new(0, 380, 0, 30)
		textBox.Position = position
		textBox.Text = text
		textBox.TextScaled = true
		textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		textBox.BorderColor3 = Color3.fromRGB(0, 170, 255)
		textBox.BorderSizePixel = 2
		textBox.Parent = frame
	end

	-- Создаем все элементы интерфейса
	styleButton(flyButton, "Enable Fly", UDim2.new(0, 10, 0, 20))
	styleTextBox(speedInput, "Enter Fly Speed", UDim2.new(0, 10, 0, 60))
	styleTextBox(speedhackInput, "Enter Speedhack Speed", UDim2.new(0, 10, 0, 100))
	styleButton(speedhackButton, "Enable Speedhack", UDim2.new(0, 10, 0, 140))
	styleButton(keybindButton, "Speedhack Key: R", UDim2.new(0, 10, 0, 180))
	styleButton(flyKeybindButton, "Fly Key: G", UDim2.new(0, 10, 0, 220))
	styleButton(teleportButton, "Teleport to Position 1", UDim2.new(0, 10, 0, 260))
	styleButton(teleportKeybindButton, "Teleport Key: T", UDim2.new(0, 10, 0, 300))
	styleButton(proximityPromptButton, "Disable ProximityPrompt", UDim2.new(0, 10, 0, 340))
	styleButton(proximityKeybindButton, "Proximity Key: J", UDim2.new(0, 10, 0, 380))
	styleButton(proximityRadarButton, "ProximityPrompt Radar: Disabled", UDim2.new(0, 10, 0, 420))
	styleTextBox(radarDistanceInput, "Radar Distance: 500", UDim2.new(0, 10, 0, 460))

	-- Настраиваем начальные цвета
	proximityRadarButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

	-- Заголовок
	titleLabel.Size = UDim2.new(0, 380, 0, 50)
	titleLabel.Position = UDim2.new(0, 10, 0, -40)
	titleLabel.Text = "chalun"
	titleLabel.TextScaled = true
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextStrokeTransparency = 0
	titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 170, 255)
	titleLabel.BackgroundTransparency = 1
	titleLabel.BorderSizePixel = 0
	titleLabel.Parent = frame

	-- Функция для обновления состояния кнопки радара
	local function updateRadarButtonState()
		if not proximityRadarButton then return end

		if proximityPromptEnabled then
			if radarEnabled then
				proximityRadarButton.Text = "ProximityPrompt Radar: Enabled"
				proximityRadarButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
			else
				proximityRadarButton.Text = "ProximityPrompt Radar: Disabled"
				proximityRadarButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			end
		else
			proximityRadarButton.Text = "ProximityPrompt Radar: Requires Bypass"
			proximityRadarButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		end
	end

	-- Функция для применения изменений ко всем промптам
	local function updateAllPrompts()
		for _, prompt in ipairs(game:GetService("Workspace"):GetDescendants()) do
			if prompt:IsA("ProximityPrompt") then
				if proximityPromptEnabled then
					if not originalDurations[prompt] then
						originalDurations[prompt] = prompt.HoldDuration
					end
					prompt.HoldDuration = 0

					if radarEnabled then
						if not originalDistances[prompt] then
							originalDistances[prompt] = prompt.MaxActivationDistance
						end
						prompt.MaxActivationDistance = radarDistance
					else
						if originalDistances[prompt] then
							prompt.MaxActivationDistance = originalDistances[prompt]
						end
					end
				else
					if originalDurations[prompt] then
						prompt.HoldDuration = originalDurations[prompt]
					end
					if originalDistances[prompt] then
						prompt.MaxActivationDistance = originalDistances[prompt]
					end
				end
			end
		end
	end

	-- Функция для включения/выключения радара
	local function toggleRadar()
		if not proximityPromptEnabled then
			return
		end

		radarEnabled = not radarEnabled

		if radarEnabled then
			for _, prompt in ipairs(game:GetService("Workspace"):GetDescendants()) do
				if prompt:IsA("ProximityPrompt") then
					if not originalDistances[prompt] then
						originalDistances[prompt] = prompt.MaxActivationDistance
					end
					prompt.MaxActivationDistance = radarDistance
				end
			end
		else
			for prompt, _ in pairs(originalDistances) do
				if prompt and prompt.Parent then
					if originalDistances[prompt] then
						prompt.MaxActivationDistance = originalDistances[prompt]
					end
				end
			end
		end

		updateRadarButtonState()
	end

	-- Обработчик новых ProximityPrompt
	local function onDescendantAdded(descendant)
		if descendant:IsA("ProximityPrompt") then
			if proximityPromptEnabled then
				originalDurations[descendant] = descendant.HoldDuration
				descendant.HoldDuration = 0

				if radarEnabled then
					if not originalDistances[descendant] then
						originalDistances[descendant] = descendant.MaxActivationDistance
					end
					descendant.MaxActivationDistance = radarDistance
				end
			end
		end
	end

	-- Подписываемся на событие добавления новых объектов
	game:GetService("Workspace").DescendantAdded:Connect(onDescendantAdded)

	-- Функция переключения ProximityPrompt
	local function toggleProximityPrompts()
		proximityPromptEnabled = not proximityPromptEnabled

		if proximityPromptEnabled then
			proximityPromptButton.Text = "Enable ProximityPrompt"
			proximityPromptButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		else
			proximityPromptButton.Text = "Disable ProximityPrompt"
			proximityPromptButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

			if radarEnabled then
				radarEnabled = false
				for prompt, _ in pairs(originalDistances) do
					if prompt and prompt.Parent then
						if originalDistances[prompt] then
							prompt.MaxActivationDistance = originalDistances[prompt]
						end
					end
				end
			end
		end

		updateAllPrompts()
		updateRadarButtonState()
	end

	-- Функция для настройки клавиши ProximityPrompt
	local function setProximityKeybind()
		proximityKeybindListening = true
		proximityKeybindButton.Text = "Press any key..."

		local connection
		connection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
			if proximityKeybindListening and not gameProcessed then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					proximityKey = input.KeyCode
					proximityKeybindButton.Text = "Proximity Key: " .. tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
					proximityKeybindListening = false
					connection:Disconnect()
				end
			end
		end)
	end

	-- Функция полета
	local function fly()
		local character = getCharacter()
		if not character then return end

		local humanoidRootPart = getHumanoidRootPart(character)
		if not humanoidRootPart then return end

		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		bodyVelocity.Parent = humanoidRootPart

		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bodyGyro.CFrame = humanoidRootPart.CFrame
		bodyGyro.Parent = humanoidRootPart

		flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
			local camera = workspace.CurrentCamera
			if not camera then return end

			local moveDirection = Vector3.new(0, 0, 0)

			if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
				moveDirection = moveDirection + (camera.CFrame.LookVector * speed)
			end
			if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
				moveDirection = moveDirection - (camera.CFrame.LookVector * speed)
			end
			if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
				moveDirection = moveDirection - (camera.CFrame.RightVector * speed)
			end
			if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
				moveDirection = moveDirection + (camera.CFrame.RightVector * speed)
			end
			if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
				moveDirection = moveDirection + Vector3.new(0, speed, 0)
			end
			if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then
				moveDirection = moveDirection - Vector3.new(0, speed, 0)
			end

			if bodyVelocity then
				bodyVelocity.Velocity = moveDirection
			end
			if bodyGyro then
				bodyGyro.CFrame = camera.CFrame
			end
		end)
	end

	-- Функция для включения/выключения полета
	local function toggleFly()
		flying = not flying
		flyButton.Text = flying and "Disable Fly" or "Enable Fly"

		if flying then
			fly()
		else
			if flyConnection then 
				flyConnection:Disconnect() 
				flyConnection = nil
			end
			if bodyVelocity then 
				bodyVelocity:Destroy() 
				bodyVelocity = nil
			end
			if bodyGyro then 
				bodyGyro:Destroy() 
				bodyGyro = nil
			end
			local character = getCharacter()
			local humanoidRootPart = getHumanoidRootPart(character)
			if humanoidRootPart then
				humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
			end
		end
	end

	-- Функция телепортации
	local function toggleTeleport()
		local character = getCharacter()
		if not character then return end

		local humanoidRootPart = getHumanoidRootPart(character)
		if not humanoidRootPart then return end

		teleportToggle = not teleportToggle

		if teleportToggle then
			humanoidRootPart.CFrame = CFrame.new(Vector3.new(170.43, 3.66, 474.95))
			teleportButton.Text = "Teleport to Position 2"
		else
			humanoidRootPart.CFrame = CFrame.new(Vector3.new(172.26, 47.47, 426.68))
			teleportButton.Text = "Teleport to Position 1"
		end
	end

	-- Функция для изменения скорости полета
	speedInput.FocusLost:Connect(function(enterPressed)
		local newSpeed = tonumber(speedInput.Text)
		if newSpeed then
			speed = newSpeed
			speedInput.Text = "Speed: " .. speed
		else
			speedInput.Text = "Invalid Input"
		end
	end)

	-- Функция для изменения скорости Speedhack
	speedhackInput.FocusLost:Connect(function(enterPressed)
		local newSpeedhackSpeed = tonumber(speedhackInput.Text)
		if newSpeedhackSpeed then
			speedhackSpeed = newSpeedhackSpeed
			local character = getCharacter()
			local humanoid = getHumanoid(character)
			if humanoid and speedhackEnabled then
				humanoid.WalkSpeed = speedhackSpeed
			end
			speedhackInput.Text = "Speedhack: " .. speedhackSpeed
		else
			speedhackInput.Text = "Invalid Input"
		end
	end)

	-- Функция для изменения расстояния радара
	radarDistanceInput.FocusLost:Connect(function(enterPressed)
		local newDistance = tonumber(radarDistanceInput.Text)
		if newDistance and newDistance > 0 then
			radarDistance = newDistance
			radarDistanceInput.Text = "Radar Distance: " .. radarDistance

			if radarEnabled then
				updateAllPrompts()
			end
		else
			radarDistanceInput.Text = "Invalid Distance"
		end
	end)

	-- Функция включения/выключения Speedhack
	local function toggleSpeedhack()
		speedhackEnabled = not speedhackEnabled
		speedhackButton.Text = speedhackEnabled and "Disable Speedhack" or "Enable Speedhack"

		local character = getCharacter()
		local humanoid = getHumanoid(character)
		if humanoid then
			if speedhackEnabled then
				humanoid.WalkSpeed = speedhackSpeed
			else
				humanoid.WalkSpeed = 16
			end
		end
	end

	-- Функция для настройки клавиши Speedhack
	local function setSpeedhackKeybind()
		keybindListening = true
		keybindButton.Text = "Press any key..."

		local connection
		connection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
			if keybindListening and not gameProcessed then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					speedhackKey = input.KeyCode
					keybindButton.Text = "Speedhack Key: " .. tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
					keybindListening = false
					connection:Disconnect()
				end
			end
		end)
	end

	-- Функция для настройки клавиши полета
	local function setFlyKeybind()
		flyKeybindListening = true
		flyKeybindButton.Text = "Press any key..."

		local connection
		connection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
			if flyKeybindListening and not gameProcessed then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					flyKey = input.KeyCode
					flyKeybindButton.Text = "Fly Key: " .. tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
					flyKeybindListening = false
					connection:Disconnect()
				end
			end
		end)
	end

	-- Функция для настройки клавиши телепортации
	local function setTeleportKeybind()
		teleportKeybindListening = true
		teleportKeybindButton.Text = "Press any key..."

		local connection
		connection = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
			if teleportKeybindListening and not gameProcessed then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					teleportKey = input.KeyCode
					teleportKeybindButton.Text = "Teleport Key: " .. tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
					teleportKeybindListening = false
					connection:Disconnect()
				end
			end
		end)
	end

	-- Обработчик нажатия клавиш для всех функций
	game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed then
			if input.KeyCode == speedhackKey then
				toggleSpeedhack()
			elseif input.KeyCode == flyKey then
				toggleFly()
			elseif input.KeyCode == teleportKey then
				toggleTeleport()
			elseif input.KeyCode == proximityKey then
				toggleProximityPrompts()
			end
		end
	end)

	-- Функция для скрытия/показа меню
	local function toggleMenu()
		menuVisible = not menuVisible
		if frame then
			frame.Visible = menuVisible
		end
	end

	-- Привязка функций к кнопкам
	flyButton.MouseButton1Click:Connect(toggleFly)
	speedhackButton.MouseButton1Click:Connect(toggleSpeedhack)
	keybindButton.MouseButton1Click:Connect(setSpeedhackKeybind)
	flyKeybindButton.MouseButton1Click:Connect(setFlyKeybind)
	teleportButton.MouseButton1Click:Connect(toggleTeleport)
	teleportKeybindButton.MouseButton1Click:Connect(setTeleportKeybind)
	proximityPromptButton.MouseButton1Click:Connect(toggleProximityPrompts)
	proximityKeybindButton.MouseButton1Click:Connect(setProximityKeybind)
	proximityRadarButton.MouseButton1Click:Connect(toggleRadar)
	toggleButton.MouseButton1Click:Connect(toggleMenu)

	-- Обновление меню после смерти
	player.CharacterAdded:Connect(function(character)
		wait(1)
		if screenGui and frame then
			screenGui.Parent = playerGui
			frame.Visible = menuVisible
		end

		local humanoid = getHumanoid(character)
		if humanoid and speedhackEnabled then
			humanoid.WalkSpeed = speedhackSpeed
		end

		if proximityPromptEnabled then
			updateAllPrompts()
		end

		updateRadarButtonState()
	end)

	-- Обработка существующих ProximityPrompt при запуске
	updateAllPrompts()
	updateRadarButtonState()

	return true
end

-- Запускаем безопасное выполнение
local success, errorMessage = pcall(safeExecute)
if not success then
	warn("Ошибка при создании меню: " .. tostring(errorMessage))
end
