local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Точки телепортации
local teleportPoints = {
    Vector3.new(172.26, 47.47, 426.68),
    Vector3.new(170.43, 3.66, 474.95)
}

-- Функция моментальной телепортации
local function instantTeleport(targetPosition)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then 
        return false
    end
    
    local rootPart = character.HumanoidRootPart
    rootPart.CFrame = CFrame.new(targetPosition)
    return true
end

-- Функция проверки достижения точки
local function isAtPosition(targetPosition, threshold)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then 
        return false
    end
    
    local rootPart = character.HumanoidRootPart
    local distance = (rootPart.Position - targetPosition).Magnitude
    return distance < threshold
end

-- Основной процесс автоматической телепортации и перезахода
local function startAutoTeleportProcess()
    -- Ждем появления персонажа
    local character = player.Character or player.CharacterAdded:Wait()
    
    -- Небольшая задержка перед началом
    wait(2)
    
    -- Телепортация по всем точкам
    for index, point in ipairs(teleportPoints) do
        print("Телепортация на точку " .. index)
        
        -- Пытаемся телепортироваться
        local success = instantTeleport(point)
        
        if success then
            -- Ждем, пока персонаж действительно телепортируется
            local waitTime = 0
            local maxWaitTime = 5 -- Максимальное время ожидания в секундах
            
            while waitTime < maxWaitTime and not isAtPosition(point, 5) do
                wait(0.1)
                waitTime = waitTime + 0.1
            end
            
            if isAtPosition(point, 5) then
                print("Успешно телепортирован на точку " .. index)
            else
                print("Не удалось подтвердить телепортацию на точку " .. index)
            end
            
            -- Небольшая пауза между телепортациями
            wait(1)
        else
            print("Ошибка телепортации на точку " .. index)
        end
    end
    
    -- После завершения всех телепортаций - перезаход
    print("Завершены все телепортации. Перезаход на сервер...")
    wait(1)
    
    -- Перезаход на другой сервер
    TeleportService:Teleport(game.PlaceId, player)
end

-- Альтернативный вариант с использованием корутин для более плавного выполнения
local function startAutoTeleportCoroutine()
    coroutine.wrap(function()
        -- Ждем появления персонажа
        local character = player.Character or player.CharacterAdded:Wait()
        
        -- Даем время на загрузку
        wait(2)
        
        -- Последовательно телепортируемся по точкам
        for i, point in ipairs(teleportPoints) do
            print("Авто-телепорт на точку " .. i)
            
            if instantTeleport(point) then
                -- Ждем подтверждения телепортации
                local confirmed = false
                for _ = 1, 50 do  -- 50 попыток по 0.1 секунды = 5 секунд максимум
                    wait(0.1)
                    if isAtPosition(point, 5) then
                        confirmed = true
                        break
                    end
                end
                
                if confirmed then
                    print("✓ Успешная телепортация на точку " .. i)
                else
                    print("✗ Проблема с телепортацией на точку " .. i)
                end
                
                wait(1) -- Пауза перед следующей точкой
            end
        end
        
        -- После всех точек - автоматический перезаход
        print("Запуск автоматического перезахода...")
        wait(2)
        TeleportService:Teleport(game.PlaceId, player)
    end)()
end

-- Запускаем процесс когда игрок загрузится
if player then
    -- Небольшая задержка перед началом автоматического процесса
    wait(1)
    startAutoTeleportCoroutine()
else
    Players.PlayerAdded:Connect(function(newPlayer)
        if newPlayer == player then
            wait(1)
            startAutoTeleportCoroutine()
        end
    end)
end

-- Обработка респавна персонажа (на случай смерти)
player.CharacterAdded:Connect(function(character)
    -- Если процесс уже запущен, не делаем ничего
    -- Или можно добавить логику перезапуска процесса при необходимости
end)

print("Автоматическая система телепортации активирована")
