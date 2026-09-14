    local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/Beta.lua"))()

    local playersService = game:GetService("Players")
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local runService = game:GetService("RunService")
    local userInputService = game:GetService("UserInputService")

    local localPlayer = playersService.LocalPlayer

    local Window = Fluent:CreateWindow({
        Title = "Grow a Chicken Fighter",
        SubTitle = "by qtieq",
        Search = true,
        Icon = "egg",
        TabWidth = 160,
        Size = UDim2.fromOffset(500, 300),
        -- Put every Dropdown popup outside the window, on the right edge,
        -- vertically centered with the UI. FluentPlus handles the positioning.
        DropdownsOutsideWindow = true,
        Acrylic = true,
        Theme = "Aqua",
        MinimizeKey = Enum.KeyCode.LeftControl,

        UserInfo = true,
        UserInfoTop = false,
        UserInfoTitle = localPlayer.DisplayName,
        UserInfoSubtitle = "User",
        UserInfoSubtitleColor = Color3.fromRGB(140, 210, 255)
    })

    -- UI ONLY: fit the window to a phone in landscape without changing gameplay logic.
    -- The iPhone XR landscape viewport is used as the reference: leave only a small
    -- top/bottom margin, using the smaller 464x368 UI window.
    task.defer(function()
        pcall(function()
            local camera = workspace.CurrentCamera
            if not camera then
                return
            end

            local viewport = camera.ViewportSize
            local isLandscapeTouch = userInputService.TouchEnabled and viewport.X > viewport.Y

            if not isLandscapeTouch then
                return
            end

            local rootFrame
            for _, instance in ipairs(Fluent.GUI:GetDescendants()) do
                if instance:IsA("Frame")
                    and instance.Size.X.Offset == 500
                    and instance.Size.Y.Offset == 300 then
                    rootFrame = instance
                    break
                end
            end

            if rootFrame then
                local margin = 10
                local scale = math.min(
                    (viewport.X - 20) / 500,
                    (viewport.Y - (margin * 2)) / 300
                )

                local uiScale = rootFrame:FindFirstChild("qtieqLandscapeScale")
                if not uiScale then
                    uiScale = Instance.new("UIScale")
                    uiScale.Name = "qtieqLandscapeScale"
                    uiScale.Parent = rootFrame
                end

                uiScale.Scale = math.clamp(scale, 0.60, 1)
            end
        end)
    end)

    -- UI ONLY: make Fluent's internal ScrollingFrames touch-scrollable.
    -- This does not alter any gameplay loop, remote, or Tower/Rebirth logic.
    task.defer(function()
        pcall(function()
            local fluentGui = Fluent.GUI
            if not fluentGui then
                return
            end

            local function enableTouchScroll(instance)
                if not instance:IsA("ScrollingFrame") then
                    return
                end

                instance.Active = true
                instance.ScrollingEnabled = true
                instance.ScrollingDirection = Enum.ScrollingDirection.Y
                instance.ElasticBehavior = Enum.ElasticBehavior.Always
                instance.ScrollBarThickness = 4

                if instance:FindFirstChildOfClass("UIListLayout") then
                    instance.AutomaticCanvasSize = Enum.AutomaticSize.Y
                end
            end

            for _, instance in ipairs(fluentGui:GetDescendants()) do
                enableTouchScroll(instance)
            end

            fluentGui.DescendantAdded:Connect(function(instance)
                task.defer(function()
                    enableTouchScroll(instance)
                end)
            end)
        end)
    end)

    local Tabs = {
        Chicken = Window:AddTab({ Title = "ไก่", Icon = "cat" }),
        Tower = Window:AddTab({ Title = "หอคอย/รีเบิร์ธ", Icon = "swords" }),
        Upgrades = Window:AddTab({ Title = "อัพบ้าน/ถังรีไซเคิล/ที่ให้อาหาร", Icon = "wrench" }),
        Farm = Window:AddTab({ Title = "ฟาร์มอัตโนมัติ", Icon = "egg" }),
        Arena = Window:AddTab({ Title = "อารีน่า", Icon = "swords" }),
        Events = Window:AddTab({ Title = "อีเว้นท์", Icon = "calendar" }),
        Settings = Window:AddTab({ Title = "ตั้งค่า", Icon = "settings" })
    }

    if getgenv().floatingMinimizeGui then
        pcall(function()
            getgenv().floatingMinimizeGui:Destroy()
        end)
    end

    if getgenv().floatingMinimizeDragConnection then
        getgenv().floatingMinimizeDragConnection:Disconnect()

        getgenv().floatingMinimizeDragConnection = nil
    end

    local floatingMinimizeGui = Instance.new("ScreenGui")
    floatingMinimizeGui.Name = "FloatingMinimizeGui"
    floatingMinimizeGui.ResetOnSpawn = false
    floatingMinimizeGui.DisplayOrder = 999999
    floatingMinimizeGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local floatingMinimizeButton = Instance.new("ImageButton")
    floatingMinimizeButton.Name = "MinimizeToggleButton"
    floatingMinimizeButton.Size = UDim2.fromOffset(44, 44)
    floatingMinimizeButton.Position = UDim2.new(0, 15, 0, 85)
    floatingMinimizeButton.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    floatingMinimizeButton.BackgroundTransparency = 0.1
    floatingMinimizeButton.BorderSizePixel = 0
    floatingMinimizeButton.AutoButtonColor = false
    floatingMinimizeButton.Image = "rbxthumb://type=Asset&id=75927350468091&w=150&h=150"
    floatingMinimizeButton.Parent = floatingMinimizeGui

    local floatingMinimizeCorner = Instance.new("UICorner")
    floatingMinimizeCorner.CornerRadius = UDim.new(1, 0)
    floatingMinimizeCorner.Parent = floatingMinimizeButton

    local attachSuccess = pcall(function()
        floatingMinimizeGui.Parent = gethui and gethui() or game:GetService("CoreGui")
    end)

    if not attachSuccess then
        local playerGui = localPlayer:WaitForChild("PlayerGui", 10)

        if playerGui then
            floatingMinimizeGui.Parent = playerGui
        end
    end

    getgenv().floatingMinimizeGui = floatingMinimizeGui

    local isDraggingButton = false
    local dragStartPosition = nil
    local dragStartButtonPosition = nil

    floatingMinimizeButton.InputBegan:Connect(function(inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
            isDraggingButton = true
            dragStartPosition = inputObject.Position
            dragStartButtonPosition = floatingMinimizeButton.Position

            inputObject.Changed:Connect(function()
                if inputObject.UserInputState == Enum.UserInputState.End then
                    isDraggingButton = false

                    if dragStartPosition and (inputObject.Position - dragStartPosition).Magnitude <= 8 then
                        pcall(function()
                            Window:Minimize()
                        end)
                    end
                end
            end)
        end
    end)

    getgenv().floatingMinimizeDragConnection = userInputService.InputChanged:Connect(function(inputObject)
        if not isDraggingButton then
            return
        end

        if inputObject.UserInputType == Enum.UserInputType.MouseMovement or inputObject.UserInputType == Enum.UserInputType.Touch then
            local dragDelta = inputObject.Position - dragStartPosition

            floatingMinimizeButton.Position = UDim2.new(
                dragStartButtonPosition.X.Scale,
                dragStartButtonPosition.X.Offset + dragDelta.X,
                dragStartButtonPosition.Y.Scale,
                dragStartButtonPosition.Y.Offset + dragDelta.Y
            )
        end
    end)

    getgenv().autoCollectEggEnabled = false
    getgenv().autoHotEggEnabled = false
    getgenv().autoHotEggLoopActive = false
    getgenv().autoCollectEggLoopActive = false
    getgenv().autoRebirthEnabled = false
    getgenv().autoRebirthLoopActive = false
    getgenv().autoUpgradeFeederEnabled = false
    getgenv().autoUpgradeFeederLoopActive = false
    getgenv().autoTowerEnabled = false
    getgenv().autoTowerLoopActive = false
    getgenv().autoTowerOfferHooked = false
    getgenv().autoTowerLastFloorEnabled = false
    getgenv().autoTowerWaitingAfterRebirth = false
    getgenv().rebirthLimit = 0
    getgenv().towerDelaySeconds = 5

    -- UFO priority: temporarily pauses ONLY Tower + Rebirth without toggling either option off.
    -- When UFO starts, an active Tower is surrendered first; when UFO ends, both systems
    -- naturally begin a fresh delay from 0 instead of carrying the previous countdown.
    getgenv().ufoPriorityActive = false
    getgenv().ufoPriorityTransitioning = false
    getgenv().autoScrapEnabled = false
        getgenv().autoIncubatorClaimEnabled = false
    getgenv().autoScrapLoopActive = false
    getgenv().autoIncubatorClaimEnabled = false
    getgenv().autoIncubatorClaimLoopActive = false
    getgenv().autoScrapNoclipConnection = nil
    getgenv().autoUpgradeCoopEnabled = false
    getgenv().autoUpgradeCoopLoopActive = false
    getgenv().autoBuyFeederEnabled = false
    getgenv().autoBuyFeederLoopActive = false
    getgenv().autoUpgradeRecyclerEnabled = false
    getgenv().autoUpgradeRecyclerLoopActive = false
    getgenv().antiAFKEnabled = false
    getgenv().antiAFKLoopActive = false
    getgenv().antiAFKDisabledConnections = {}
    getgenv().autoPromoteEnabled = false
    getgenv().autoPromoteLoopActive = false
    getgenv().autoPromoteSelected = getgenv().autoPromoteSelected or {}
    getgenv().autoSellEnabled = false
    getgenv().autoSellSelectedRarities = getgenv().autoSellSelectedRarities or {}
    getgenv().autoSellKeepRarities = getgenv().autoSellKeepRarities or {}
    getgenv().autoSellKeepMutations = getgenv().autoSellKeepMutations or {}
    getgenv().autoSellLoopActive = false

    local remotesModule = nil
    local rebirthBonusModule = nil
    local rebirthExperimentModule = nil
    local dataControllerModule = nil
    local promotionViewModule = nil
    local localeModule = nil
    local coopViewModule = nil
    local dataServiceModule = nil
    local chickenModeModule = nil
    local recyclerViewModule = nil

    pcall(function()
        remotesModule = require(replicatedStorage:WaitForChild("Core", 10):WaitForChild("Remotes", 10))
    end)

    pcall(function()
        local progressionFolder = replicatedStorage:WaitForChild("Core", 10):WaitForChild("Progression", 10)

        rebirthBonusModule = require(progressionFolder:WaitForChild("RebirthBonus", 10))
        rebirthExperimentModule = require(progressionFolder:WaitForChild("RebirthExperiment", 10))
    end)

    pcall(function()
        dataControllerModule = require(localPlayer:WaitForChild("PlayerScripts", 10):WaitForChild("Core", 10):WaitForChild("Data", 10):WaitForChild("DataController", 10))
    end)

    pcall(function()
        promotionViewModule = require(replicatedStorage:WaitForChild("Features", 10):WaitForChild("Chicken", 10):WaitForChild("PromotionView", 10))
    end)

    pcall(function()
        localeModule = require(localPlayer:WaitForChild("PlayerScripts", 10):WaitForChild("UI", 10):WaitForChild("Locale", 10))
    end)

    pcall(function()
        coopViewModule = require(replicatedStorage:WaitForChild("Features", 10):WaitForChild("Coop", 10):WaitForChild("CoopView", 10))
    end)

    pcall(function()
        dataServiceModule = require(replicatedStorage:WaitForChild("Packages", 10):WaitForChild("DataService", 10))
    end)

    pcall(function()
        chickenModeModule = require(localPlayer:WaitForChild("PlayerScripts", 10):WaitForChild("Features", 10):WaitForChild("Chicken", 10):WaitForChild("ChickenMode", 10))
    end)

    pcall(function()
        recyclerViewModule = require(replicatedStorage:WaitForChild("Features", 10):WaitForChild("Scrap", 10):WaitForChild("RecyclerView", 10))
    end)

    local function getEggOwner(eggInstance)
        local ownerValue = eggInstance:GetAttribute("owner")

        if ownerValue ~= nil then
            return ownerValue
        end

        local eggPart = eggInstance:FindFirstChildWhichIsA("BasePart", true)

        if eggPart then
            return eggPart:GetAttribute("owner")
        end

        return nil
    end

    local function getEggPosition(eggInstance)
        if eggInstance:IsA("BasePart") then
            return eggInstance.Position
        end

        if eggInstance:IsA("Model") then
            return eggInstance:GetPivot().Position
        end

        local eggPart = eggInstance:FindFirstChildWhichIsA("BasePart", true)

        if eggPart then
            return eggPart.Position
        end

        return nil
    end

    local function getOwnedEggPositions()
        local ownedEggPositions = {}
        local nestEggsFolder = workspace:FindFirstChild("NestEggs")

        if not nestEggsFolder then
            return ownedEggPositions
        end

        for _, eggInstance in ipairs(nestEggsFolder:GetChildren()) do
            local success, ownerValue = pcall(getEggOwner, eggInstance)

            if success and (ownerValue == localPlayer.UserId or ownerValue == tostring(localPlayer.UserId)) then
                local positionSuccess, eggPosition = pcall(getEggPosition, eggInstance)

                if positionSuccess and eggPosition then
                    table.insert(ownedEggPositions, eggPosition)
                end
            end
        end

        return ownedEggPositions
    end

    -- Standstill Egg Collection: collect owned eggs without moving the character.
    -- Uses the same physical touch pickup the game uses when the player walks onto an egg.
    local function collectEggStandstill(eggInstance)
        if not eggInstance then
            return
        end

        local character = localPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            return
        end

        local touchFunction = firetouchinterest
        if type(touchFunction) ~= "function" then
            return
        end

        local parts = {}
        if eggInstance:IsA("BasePart") then
            table.insert(parts, eggInstance)
        else
            for _, instance in ipairs(eggInstance:GetDescendants()) do
                if instance:IsA("BasePart") then
                    table.insert(parts, instance)
                end
            end
        end

        for _, eggPart in ipairs(parts) do
            if not getgenv().autoCollectEggEnabled then
                return
            end

            pcall(function()
                touchFunction(rootPart, eggPart, 0)
                touchFunction(rootPart, eggPart, 1)
            end)
        end
    end

    local function getOwnedEggs()
        local ownedEggs = {}
        local nestEggsFolder = workspace:FindFirstChild("NestEggs")

        if not nestEggsFolder then
            return ownedEggs
        end

        for _, eggInstance in ipairs(nestEggsFolder:GetChildren()) do
            local success, ownerValue = pcall(getEggOwner, eggInstance)
            if success and (ownerValue == localPlayer.UserId or ownerValue == tostring(localPlayer.UserId)) then
                table.insert(ownedEggs, eggInstance)
            end
        end

        return ownedEggs
    end

    local function isRebirthReady()
        local rebirthData = dataControllerModule.rebirth()
        local rebirthCount = rebirthData and rebirthData.count or 0
        local towerBestFloor = dataControllerModule.towerBest() or 0
        local usesV2Formula = rebirthExperimentModule.armOf(localPlayer) == rebirthExperimentModule.VARIANT

        return rebirthBonusModule.ready(towerBestFloor, rebirthCount, usesV2Formula)
    end

    local function isRebirthLimitReached()
        if not dataControllerModule then
            return false
        end

        local limit = tonumber(getgenv().rebirthLimit) or 0
        limit = math.clamp(math.floor(limit), 0, 20000)
        if limit <= 0 then
            return false
        end

        local success, rebirthData = pcall(function()
            return dataControllerModule.rebirth()
        end)

        if not success or type(rebirthData) ~= "table" then
            return false
        end

        local currentRebirth = tonumber(rebirthData.count) or 0
        return currentRebirth >= limit
    end

    local function isRebirthPending()
        if not (rebirthBonusModule and rebirthExperimentModule and dataControllerModule) then
            return false
        end

        local readySuccess, isReady = pcall(isRebirthReady)

        return readySuccess and isReady == true
    end

    local function requestRebirth()
        local result = remotesModule.invoke(remotesModule.defs.Rebirth)

        return typeof(result) == "table" and result.ok == true
    end

    local function getCurrentMoney()
        local moneyObject = dataControllerModule.money()

        if moneyObject and moneyObject.toNumber then
            return moneyObject:toNumber()
        end

        return 0
    end

    local function getCoopData()
        local dataClient = dataServiceModule.client

        return dataClient and dataClient:get({ "coop" })
    end

    local function upgradeFeeders()
        local coopData = getCoopData()

        if not coopData or type(coopData.generators) ~= "table" then
            return
        end

        for _, generatorData in ipairs(coopData.generators) do
            if not getgenv().autoUpgradeFeederEnabled then
                return
            end

            local feederSlot = tonumber(generatorData.slot)
            local feederLevel = tonumber(generatorData.level)

            if feederSlot and feederLevel and coopViewModule.canUpgrade(feederLevel) then
                local upgradeCost = coopViewModule.upgradeCost(feederLevel)

                if getCurrentMoney() >= upgradeCost then
                    local result = remotesModule.invoke(remotesModule.defs.UpgradeGenerator, feederSlot)

                    if typeof(result) == "table" and result.ok then
                        task.wait(0.25)
                    end
                end
            end
        end
    end

    local function isTowerRunActive()
        return localPlayer:GetAttribute("TowerActive") == true
    end

    local function surrenderTowerForRebirth()
        if not isTowerRunActive() then
            return true
        end
     
        pcall(function()
            remotesModule.invoke(remotesModule.defs.TowerSurrender)
        end)
     
        local waitStart = os.clock()
        while isTowerRunActive() and os.clock() - waitStart < 5 do
            task.wait(0.1)
        end
     
        return not isTowerRunActive()
    end
    local function startTowerRun()
        if getgenv().autoTowerLastFloorEnabled and dataControllerModule then
            local lastTowerFloor = tonumber(dataControllerModule.towerBest()) or 0

            if lastTowerFloor > 0 then
                remotesModule.invoke(remotesModule.defs.TowerElevator, lastTowerFloor)
            end
        end

        if chickenModeModule then
            chickenModeModule.order("tower")
        end

        remotesModule.invoke(remotesModule.defs.TowerStart)
    end

    local function surrenderTower()
        local result = remotesModule.invoke(remotesModule.defs.TowerSurrender)

        return typeof(result) == "table" and result.ok == true
    end

    -- UFO priority transition. This does NOT change the Tower/Rebirth toggles.
    -- It only blocks their work while the UFO event is active and resets their delay
    -- implicitly by forcing their loops to start a new countdown after the event ends.
    local function setUFOPriorityActive(active)
        active = active == true

        if active then
            if getgenv().ufoPriorityActive then
                return
            end

            getgenv().ufoPriorityTransitioning = true

            -- UFO starts: surrender immediately. Do not check TowerActive first.
            if remotesModule then
                pcall(function()
                    remotesModule.invoke(remotesModule.defs.TowerSurrender)
                end)

                local waitStart = os.clock()
                while isTowerRunActive() and os.clock() - waitStart < 5 do
                    task.wait(0.1)
                end
            end

            getgenv().ufoPriorityActive = true
            getgenv().ufoPriorityTransitioning = false
            return
        end

        -- UFO ended: clear the pause. Tower/Rebirth loops will start fresh timing.
        getgenv().ufoPriorityTransitioning = false
        getgenv().ufoPriorityActive = false
        getgenv().ufoPetCooldownUntil = os.clock() + 15
    end

    local function hookTowerContinueOffer()
        if getgenv().autoTowerOfferHooked then
            return
        end

        getgenv().autoTowerOfferHooked = true

        remotesModule.onClient(remotesModule.defs.TowerContinueOffer, function(offerData)
            if getgenv().autoTowerEnabled and typeof(offerData) == "table" and offerData.open == true then
                pcall(function()
                    remotesModule.fire(remotesModule.defs.TowerContinueDecline)
                end)
            end
        end)
    end

    local function getScrapStackCount()
        local playerCharacter = localPlayer.Character

        if not playerCharacter then
            return 0
        end

        local playerHead = playerCharacter:FindFirstChild("Head")

        if not playerHead then
            return 0
        end

        local scrapStack = playerHead:FindFirstChild("ScrapStack")

        if not scrapStack then
            return 0
        end

        local stackCount = 0

        for _, stackPart in ipairs(scrapStack:GetDescendants()) do
            if stackPart:IsA("BasePart") then
                stackCount = stackCount + 1
            end
        end

        return stackCount
    end

    local function getOwnedRecycler()
        local recyclersFolder = workspace:FindFirstChild("Recyclers")

        if not recyclersFolder then
            return nil
        end

        local plotNumber = localPlayer:GetAttribute("Plot")

        if plotNumber then
            local recyclerModel = recyclersFolder:FindFirstChild("Recycler" .. tostring(plotNumber))

            if recyclerModel then
                return recyclerModel
            end
        end

        for _, recyclerModel in ipairs(recyclersFolder:GetChildren()) do
            local success, recyclerOwner = pcall(function()
                return recyclerModel:GetAttribute("owner")
            end)

            if success and (recyclerOwner == localPlayer.UserId or recyclerOwner == tostring(localPlayer.UserId)) then
                return recyclerModel
            end
        end

        return nil
    end

    local function startScrapNoclip()
        if getgenv().autoScrapNoclipConnection then
            return
        end

        getgenv().autoScrapNoclipConnection = runService.Stepped:Connect(function()
            local playerCharacter = localPlayer.Character

            if not playerCharacter then
                return
            end

            for _, characterPart in ipairs(playerCharacter:GetDescendants()) do
                if characterPart:IsA("BasePart") and characterPart.CanCollide then
                    characterPart.CanCollide = false
                end
            end
        end)
    end

    local function stopScrapNoclip()
        if getgenv().autoScrapNoclipConnection then
            getgenv().autoScrapNoclipConnection:Disconnect()

            getgenv().autoScrapNoclipConnection = nil
        end
    end

    local function walkToPosition(playerHumanoid, targetPosition)
        local moveStartTime = os.clock()
        local lastMoveRequest = 0

        while getgenv().autoScrapEnabled do
            local currentCharacter = localPlayer.Character
            local currentHumanoid = currentCharacter and currentCharacter:FindFirstChildOfClass("Humanoid")
            local currentRootPart = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")

            if not currentHumanoid or not currentRootPart then
                return
            end

            if (currentRootPart.Position - targetPosition).Magnitude <= 5 then
                return
            end

            if os.clock() - lastMoveRequest >= 1 then
                currentHumanoid:MoveTo(targetPosition)

                lastMoveRequest = os.clock()
            end

            if os.clock() - moveStartTime >= 20 then
                return
            end

            task.wait(0.15)
        end
    end

    local function depositAtRecycler()
        local recyclerModel = getOwnedRecycler()

        if not recyclerModel then
            return
        end

        local recyclerPosition = recyclerModel:GetPivot().Position
        local playerCharacter = localPlayer.Character
        local playerHumanoid = playerCharacter and playerCharacter:FindFirstChildOfClass("Humanoid")

        if not playerHumanoid then
            return
        end

        walkToPosition(playerHumanoid, recyclerPosition)

        local waitStartTime = os.clock()

        while getgenv().autoScrapEnabled do
            local currentCharacter = localPlayer.Character
            local currentRootPart = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")

            if not currentRootPart then
                return
            end

            if (currentRootPart.Position - recyclerPosition).Magnitude > 12 then
                break
            end

            if getScrapStackCount() <= 0 then
                break
            end

            if os.clock() - waitStartTime >= 20 then
                break
            end

            task.wait(0.5)
        end
    end

    local function collectNearbyScrap()
        local pitScrapFolder = workspace:FindFirstChild("PitScrap")

        if not pitScrapFolder then
            return
        end

        local scrapParts = {}

        for _, scrapInstance in ipairs(pitScrapFolder:GetChildren()) do
            if scrapInstance:IsA("BasePart") then
                table.insert(scrapParts, scrapInstance)
            end
        end

        if #scrapParts == 0 then
            return
        end

        local playerCharacter = localPlayer.Character
        local playerHumanoid = playerCharacter and playerCharacter:FindFirstChildOfClass("Humanoid")
        local rootPart = playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart")

        if not playerHumanoid or not rootPart then
            return
        end

        table.sort(scrapParts, function(partA, partB)
            return (partA.Position - rootPart.Position).Magnitude < (partB.Position - rootPart.Position).Magnitude
        end)

        for _, scrapPart in ipairs(scrapParts) do
            if not getgenv().autoScrapEnabled then
                return
            end

            if getScrapStackCount() > 6 then
                return
            end

            if scrapPart.Parent then
                walkToPosition(playerHumanoid, scrapPart.Position)
            end
        end
    end

    local function upgradeCoop()
        local coopData = getCoopData()

        if not coopData or type(coopData.slots) ~= "number" then
            return false
        end

        local coopSlots = coopData.slots

        if not coopViewModule.canExpand(coopSlots) then
            return false
        end

        local expandCost = coopViewModule.expandCost(coopSlots)

        if getCurrentMoney() < expandCost then
            return false
        end

        local result = remotesModule.invoke(remotesModule.defs.ExpandCoop)

        return typeof(result) == "table" and result.ok == true
    end

    local function buyFeeder()
        local coopData = getCoopData()

        if not coopData or type(coopData.slots) ~= "number" or type(coopData.generators) ~= "table" then
            return false
        end

        local feederCount = #coopData.generators

        if not coopViewModule.canBuyGenerator(coopData.slots, feederCount) then
            return false
        end

        local buyCost = coopViewModule.buyGeneratorCost(feederCount)

        if getCurrentMoney() < buyCost then
            return false
        end

        local result = remotesModule.invoke(remotesModule.defs.BuyGenerator, feederCount + 1)

        return typeof(result) == "table" and result.ok == true
    end

    local function getRecyclerState()
        local dataClient = dataServiceModule.client

        if not dataClient then
            return nil
        end

        local scrapData = dataClient:get({ "scrap" })

        if not scrapData then
            return nil
        end

        local recyclerLevel = scrapData.recyclerLevel or 0
        local towerData = dataClient:get({ "tower" })
        local rebirthData = dataClient:get({ "rebirth" })
        local towerBestFloor = 0
        local rebirthCount = 0

        if towerData then
            towerBestFloor = towerData.best or 0
        end

        if type(rebirthData) == "table" then
            rebirthCount = rebirthData.count or 0
        elseif type(rebirthData) == "number" then
            rebirthCount = rebirthData
        end

        return {
            level = recyclerLevel,
            canUpgrade = recyclerViewModule.canUpgrade(recyclerLevel, rebirthCount),
            upgradeCost = recyclerViewModule.upgradeCost(recyclerLevel),
            floorUnlocked = recyclerViewModule.floorUnlocked(recyclerLevel, towerBestFloor),
            locked = localPlayer:GetAttribute(recyclerViewModule.LockedAttr) == true,
            busy = localPlayer:GetAttribute(recyclerViewModule.BusyAttr) == true
        }
    end

    local function upgradeRecycler()
        local recyclerState = getRecyclerState()

        if not recyclerState then
            return false
        end

        if recyclerState.locked or recyclerState.busy or not recyclerState.floorUnlocked or not recyclerState.canUpgrade then
            return false
        end

        if getCurrentMoney() < recyclerState.upgradeCost then
            return false
        end

        local result = remotesModule.invoke(remotesModule.defs.UpgradeRecycler)

        return typeof(result) == "table" and result.ok == true
    end

    local autoUFORunning = false
    local autoUFOLoopActive = false
    local ufoEventActive = false
    local ufoSequenceRunning = false
    -- Saved active chicken for the current UFO round only.
    -- This is captured once when the UFO round starts and reset when it ends.
    local ufoOriginalActiveChickenId = nil
    local ufoOriginalChickenCaptured = false
    local ufoPostEndCooldownUntil = 0
    local ufoChickenDropdown = nil
    local ufoChickenRefreshButton = nil
    local ufoChickenOptionToId = {}
    local ufoSelectedChickenId = nil
    local lastChaosFire = 0
    local lastLiveEventCheck = 0
    local ufoEndHandled = false
    getgenv().ufoPetCooldownUntil = getgenv().ufoPetCooldownUntil or 0

    local ufoRemotes = replicatedStorage:WaitForChild("Remotes")
    local setChickenOrder = ufoRemotes:WaitForChild("SetChickenOrder")
    local liveEventGetActive = ufoRemotes:FindFirstChild("LiveEventGetActive")

    local function getUFOChickenRoster()
        if not dataControllerModule then
            return nil
        end

        local ok, roster = pcall(function()
            return dataControllerModule.roster()
        end)

        if not ok or type(roster) ~= "table" or type(roster.chickens) ~= "table" then
            return nil
        end

        return roster
    end

    local function getUFOChickenDisplayName(chicken)
        local typeId = chicken and chicken.typeId
        if localeModule and typeId then
            local ok, name = pcall(function()
                return localeModule.chicken(typeId)
            end)
            if ok and type(name) == "string" and name ~= "" then
                return name
            end
        end

        return tostring(typeId or "Unknown Chicken")
    end

    local function refreshUFOChickenList()
        ufoChickenOptionToId = {}

        local roster = getUFOChickenRoster()
        if not roster or not ufoChickenDropdown then
            return
        end

        -- Keep the exact order supplied by the game's roster/inventory data.
        -- Do not alphabetically sort the chicken list.
        local chickens = table.clone(roster.chickens or {})

        local options = {}
        local selectedOption = nil

        for _, chicken in ipairs(chickens) do
            if chicken and chicken.id ~= nil then
                local id = tostring(chicken.id)
                local option = string.format("%s [%s]", getUFOChickenDisplayName(chicken), id)
                ufoChickenOptionToId[option] = id
                table.insert(options, option)
                if tostring(ufoSelectedChickenId or "") == id then
                    selectedOption = option
                end
            end
        end

        pcall(function()
            ufoChickenDropdown:SetValues(options)
            if selectedOption then
                ufoChickenDropdown:SetValue(selectedOption)
            end
        end)
    end

    local function captureUFOOriginalChicken()
        if ufoOriginalChickenCaptured then
            return
        end

        ufoOriginalChickenCaptured = true
        ufoOriginalActiveChickenId = nil

        local roster = getUFOChickenRoster()
        if roster and roster.activeId ~= nil and tostring(roster.activeId) ~= "" then
            ufoOriginalActiveChickenId = tostring(roster.activeId)
        end
    end

    local function restoreUFOOriginalChicken()
        local id = ufoOriginalActiveChickenId

        if id == nil or tostring(id) == "" then
            return true
        end

        if not remotesModule or not remotesModule.defs or not remotesModule.defs.SetActiveChicken then
            return false
        end

        local ok, result = pcall(function()
            return remotesModule.invoke(remotesModule.defs.SetActiveChicken, id)
        end)

        if not ok then
            return false
        end

        if result == nil then
            return true
        end

        if typeof(result) == "table" then
            return result.ok ~= false
        end

        return result ~= false
    end

    local function resetUFOOriginalChicken()
        ufoOriginalActiveChickenId = nil
        ufoOriginalChickenCaptured = false
    end

    local function deploySelectedUFOChicken()
        local id = ufoSelectedChickenId
        if id == nil or tostring(id) == "" then
            return true
        end

        if not remotesModule or not remotesModule.defs or not remotesModule.defs.SetActiveChicken then
            return false
        end

        local ok, result = pcall(function()
            return remotesModule.invoke(remotesModule.defs.SetActiveChicken, id)
        end)

        if not ok then
            return false
        end

        if result == nil then
            return true
        end

        if typeof(result) == "table" then
            return result.ok ~= false
        end

        return result ~= false
    end

    local function fireChaos()
        if not autoUFORunning or not ufoEventActive then
            return
        end

        if os.clock() - lastChaosFire < 0.5 then
            return
        end

        lastChaosFire = os.clock()
        pcall(function()
            setChickenOrder:FireServer("chaos")
        end)
    end

    -- UFO ended: if SetChickenOrder still exists, switch back to coop exactly once
    -- before releasing the paused automation systems.
    local function fireCoopAfterUFO()
        local coopRemote = ufoRemotes:FindFirstChild("SetChickenOrder")

        if not coopRemote or not coopRemote:IsA("RemoteEvent") then
            return
        end

        pcall(function()
            coopRemote:FireServer("coop")
        end)
    end

    local function finishUFOEvent()
        if not autoUFORunning then
            return
        end

        if ufoEndHandled then
            return
        end

        ufoEndHandled = true
        -- Block delayed/duplicate LiveEvent start signals that can arrive after
        -- the event has already ended and after the chicken has been restored.
        ufoPostEndCooldownUntil = os.clock() + 3

        -- UFO ended: return to COOP first, then wait 1.5 seconds before
        -- restoring the chicken that was active at the beginning of THIS round.
        -- Keep Tower/Rebirth paused until the chicken restore has been attempted.
        fireCoopAfterUFO()
        task.wait(1.5)
        pcall(restoreUFOOriginalChicken)
        resetUFOOriginalChicken()
        setUFOPriorityActive(false)
        ufoEventActive = false
    end

    local function valueSaysUFO(value, depth, seen)
        depth = depth or 0
        seen = seen or {}

        if depth > 5 then
            return false
        end

        local valueType = typeof(value)

        if valueType == "string" then
            local text = string.lower(value)
            return text:find("ufo", 1, true) ~= nil
                or text:find("invasion", 1, true) ~= nil
        end

        if valueType ~= "table" then
            return false
        end

        if seen[value] then
            return false
        end

        seen[value] = true

        for k, v in pairs(value) do
            if valueSaysUFO(k, depth + 1, seen) or valueSaysUFO(v, depth + 1, seen) then
                return true
            end
        end

        return false
    end

    local function payloadSaysUFO(...)
        for _, value in ipairs({...}) do
            if valueSaysUFO(value) then
                return true
            end
        end

        return false
    end

    local function queryLiveEventForUFO()
        if not liveEventGetActive or not liveEventGetActive:IsA("RemoteFunction") then
            liveEventGetActive = ufoRemotes:FindFirstChild("LiveEventGetActive")
        end

        if not liveEventGetActive or not liveEventGetActive:IsA("RemoteFunction") then
            return nil
        end

        local ok, result = pcall(function()
            return liveEventGetActive:InvokeServer()
        end)

        if not ok then
            return nil
        end

        return valueSaysUFO(result)
    end

    local function connectEventRemote(name, callback)
        local remote = ufoRemotes:FindFirstChild(name)

        if remote and remote:IsA("RemoteEvent") then
            remote.OnClientEvent:Connect(function(...)
                pcall(callback, ...)
            end)
        end
    end

    local function isUFOEventName(name)
        local lowerName = string.lower(tostring(name))
        return lowerName:find("ufo", 1, true) ~= nil
            or lowerName:find("invasion", 1, true) ~= nil
            or lowerName:find("liveevent", 1, true) ~= nil
    end

    local function looksLikeEventStart(name)
        local lowerName = string.lower(tostring(name))
        return lowerName:find("start", 1, true) ~= nil
            or lowerName:find("state", 1, true) ~= nil
            or lowerName:find("signal", 1, true) ~= nil
            or lowerName:find("resume", 1, true) ~= nil
    end

    local function looksLikeEventEnd(name)
        return string.lower(tostring(name)):find("end", 1, true) ~= nil
    end

    local function startUFOSequence()
        if os.clock() < ufoPostEndCooldownUntil then
            ufoEventActive = false
            return
        end

        if not autoUFORunning or not ufoEventActive or ufoSequenceRunning then
            return
        end

        ufoSequenceRunning = true

        -- Capture the active chicken once for this UFO round. Retries must NOT
        -- overwrite it after the selected chicken has been deployed.
        captureUFOOriginalChicken()

        task.spawn(function()
            -- If a chicken is selected, wait 1.5 seconds after UFO starts,
            -- deploy that chicken, and only then allow Chaos.
            if ufoSelectedChickenId ~= nil and tostring(ufoSelectedChickenId) ~= "" then
                task.wait(1.5)

                if not autoUFORunning or not ufoEventActive then
                    ufoSequenceRunning = false
                    return
                end

                local deployed = deploySelectedUFOChicken()
                if not deployed then
                    -- Never enter Chaos before the selected chicken is deployed.
                    ufoSequenceRunning = false
                    return
                end
            end

            if autoUFORunning and ufoEventActive then
                fireChaos()
            end

            ufoSequenceRunning = false
        end)
    end

    local function hookUFOEventRemotes()
        for _, remote in ipairs(ufoRemotes:GetChildren()) do
            if remote:IsA("RemoteEvent") and isUFOEventName(remote.Name) then
                if remote:GetAttribute("qtieqUFOHooked") then
                    continue
                end

                remote:SetAttribute("qtieqUFOHooked", true)

                remote.OnClientEvent:Connect(function(...)
                    if not autoUFORunning then
                        return
                    end

                    local payloadIsUFO = payloadSaysUFO(...)
                    local startSignal = looksLikeEventStart(remote.Name)
                    local endSignal = looksLikeEventEnd(remote.Name)

                    if endSignal and payloadIsUFO then
                        finishUFOEvent()
                    elseif (startSignal or payloadIsUFO) and payloadIsUFO and os.clock() >= ufoPostEndCooldownUntil then
                        ufoEventActive = true
                        ufoEndHandled = false
                        setUFOPriorityActive(true)
                        startUFOSequence()
                    end
                end)
            end
        end
    end

    -- Explicit hooks kept for the known LiveEvent signal names.
    for _, name in ipairs({
        "LiveEventStarted",
        "LiveEventStateChanged",
        "LiveEventClientSignal",
        "LiveEventSignal",
        "LiveEventResumed",
    }) do
        connectEventRemote(name, function(...)
            if autoUFORunning and os.clock() >= ufoPostEndCooldownUntil and payloadSaysUFO(...) then
                ufoEventActive = true
                ufoEndHandled = false
                setUFOPriorityActive(true)
                startUFOSequence()
            end
        end)
    end

    connectEventRemote("LiveEventEnded", function(...)
        if payloadSaysUFO(...) then
            finishUFOEvent()
        end
    end)

    -- Also hook matching UFO/INVASION/LiveEvent RemoteEvents that exist under
    -- ReplicatedStorage.Remotes, including ones added after the script starts.
    hookUFOEventRemotes()

    ufoRemotes.ChildAdded:Connect(function(child)
        task.defer(function()
            if child:IsA("RemoteEvent") and isUFOEventName(child.Name) then
                hookUFOEventRemotes()
            end
        end)
    end)

    local function isToChaosVisible()
        for _, obj in ipairs(game:GetDescendants()) do
            if obj:IsA("TextButton") or obj:IsA("TextLabel") then
                local ok, value = pcall(function()
                    return obj.Text
                end)

                if ok and typeof(value) == "string"
                    and string.upper(value):gsub("%s+", " ") == "TO CHAOS" then
                    return true
                end
            end
        end

        return false
    end

    local function startAutoUFOLoop()
        if autoUFOLoopActive then
            return
        end

        autoUFOLoopActive = true

        task.spawn(function()
            while autoUFORunning do
                -- Primary detection: ask the game's LiveEvent service which event is active.
                -- The dump shows LiveEventGetActive exists as a RemoteFunction, so this
                -- avoids depending entirely on the visible "TO CHAOS" text.
                if os.clock() - lastLiveEventCheck >= 1 then
                    lastLiveEventCheck = os.clock()

                    local activeSaysUFO = queryLiveEventForUFO()
                    if activeSaysUFO ~= nil then
                        if activeSaysUFO and os.clock() >= ufoPostEndCooldownUntil then
                            ufoEventActive = true
                            ufoEndHandled = false
                            setUFOPriorityActive(true)
                            startUFOSequence()
                        elseif not activeSaysUFO and os.clock() >= ufoPostEndCooldownUntil then
                            finishUFOEvent()
                        end
                    end
                end

                if os.clock() < ufoPostEndCooldownUntil then
                    ufoEventActive = false
                end

                -- Keep retrying the sequence if a start signal was missed or
                -- the selected chicken could not be deployed on the first attempt.
                if ufoEventActive and not ufoSequenceRunning then
                    startUFOSequence()
                end

                task.wait(0.15)
            end

            autoUFOLoopActive = false
        end)
    end

    -- ANTI AFK
    -- Disables the LocalPlayer.Idled connections while enabled.
    -- The exact connections disabled by this feature are remembered so they can
    -- be restored when the Toggle is turned OFF or when the script is unloaded.
    local function getAFKConnections()
        local getter = getconnections or get_signal_cons
        if not getter then
            return nil
        end

        local ok, result = pcall(function()
            return getter(localPlayer.Idled)
        end)

        if not ok or type(result) ~= "table" then
            return nil
        end

        return result
    end

    local function disableAntiAFKConnections()
        local connections = getAFKConnections()
        if not connections then
            return false
        end

        local disabledAny = false

        for _, connection in ipairs(connections) do
            if connection and connection.Disable then
                local alreadyStored = false

                for _, storedConnection in ipairs(getgenv().antiAFKDisabledConnections) do
                    if storedConnection == connection then
                        alreadyStored = true
                        break
                    end
                end

                if not alreadyStored then
                    local ok = pcall(function()
                        connection:Disable()
                    end)

                    if ok then
                        table.insert(getgenv().antiAFKDisabledConnections, connection)
                        disabledAny = true
                    end
                else
                    pcall(function()
                        connection:Disable()
                    end)
                end
            end
        end

        return disabledAny
    end

    local function restoreAntiAFKConnections()
        for _, connection in ipairs(getgenv().antiAFKDisabledConnections) do
            if connection and connection.Enable then
                pcall(function()
                    connection:Enable()
                end)
            end
        end

        table.clear(getgenv().antiAFKDisabledConnections)
    end

    local function setAntiAFKEnabled(enabled)
        enabled = enabled == true
        getgenv().antiAFKEnabled = enabled

        if not enabled then
            restoreAntiAFKConnections()
            return
        end

        disableAntiAFKConnections()

        if getgenv().antiAFKLoopActive then
            return
        end

        getgenv().antiAFKLoopActive = true

        task.spawn(function()
            while getgenv().antiAFKEnabled do
                -- Re-scan periodically so connections added later are also disabled.
                pcall(disableAntiAFKConnections)
                task.wait(2)
            end

            getgenv().antiAFKLoopActive = false
        end)
    end

    -- UNLOAD: stop all automation loops and destroy the UI.
    local function unloadScript()
        getgenv().autoCollectEggEnabled = false
        getgenv().autoHotEggEnabled = false
        getgenv().autoRebirthEnabled = false
        getgenv().autoUpgradeFeederEnabled = false
        getgenv().autoTowerEnabled = false
        getgenv().autoScrapEnabled = false
        getgenv().autoUpgradeCoopEnabled = false
        getgenv().autoBuyFeederEnabled = false
        getgenv().autoUpgradeRecyclerEnabled = false
        getgenv().autoPetEnabled = false
        getgenv().autoArenaEnabled = false
        getgenv().autoPromoteEnabled = false
        getgenv().autoSellEnabled = false
        setAntiAFKEnabled(false)
        autoUFORunning = false
        ufoEventActive = false
        resetUFOOriginalChicken()
        setUFOPriorityActive(false)
        liveEventGetActive = nil

        pcall(stopScrapNoclip)

        pcall(function()
            if getgenv().floatingMinimizeDragConnection then
                getgenv().floatingMinimizeDragConnection:Disconnect()
                getgenv().floatingMinimizeDragConnection = nil
            end
            if getgenv().floatingMinimizeGui then
                getgenv().floatingMinimizeGui:Destroy()
                getgenv().floatingMinimizeGui = nil
            end
        end)

        pcall(function()
            if Window.Destroy then
                Window:Destroy()
            elseif Window.Close then
                Window:Close()
            elseif Fluent.Unload then
                Fluent:Unload()
            end
        end)

        getgenv().qtieqUnloaded = true
    end

    -- Auto Sell child lists are declared before the collapse helper because the main
    -- Auto Sell group also needs to reveal the nested selectable controls.
    local autoSellChildren = {}
    local autoSellRarityChildren = {}
    local autoSellKeepRarityChildren = {}
    local autoSellKeepMutationChildren = {}

    -- COLLAPSIBLE CONTROL GROUPS / SEPARATE TOGGLE SWITCH
    -- The row area controls expand/collapse (for grouped toggles only).
    -- The switch area on the far right is the ONLY place that changes ON/OFF.
    local function setControlVisible(control, visible)
        if not control then return end
        pcall(function()
            if control.Elements and control.Elements.Frame then
                control.Elements.Frame.Visible = visible
            elseif control.Frame then
                control.Frame.Visible = visible
            end
        end)
    end

    local function setupToggleInteraction(toggle, rowCallback)
        task.defer(function()
            if not toggle or not toggle.Elements or not toggle.Elements.Frame then
                return
            end

            local frame = toggle.Elements.Frame

            -- Cover the whole row so FluentPlus' original row-click handler cannot
            -- toggle the setting. Only the dedicated switch button below can do that.
            local oldRowButton = frame:FindFirstChild("qtieqToggleRowButton")
            if oldRowButton then
                oldRowButton:Destroy()
            end

            local oldSwitchButton = frame:FindFirstChild("qtieqToggleSwitchButton")
            if oldSwitchButton then
                oldSwitchButton:Destroy()
            end

            local rowButton = Instance.new("TextButton")
            rowButton.Name = "qtieqToggleRowButton"
            rowButton.BackgroundTransparency = 1
            rowButton.BorderSizePixel = 0
            rowButton.AutoButtonColor = false
            rowButton.Text = ""
            rowButton.TextTransparency = 1
            rowButton.Size = UDim2.new(1, -62, 1, 0)
            rowButton.Position = UDim2.fromOffset(0, 0)
            rowButton.ZIndex = 150
            rowButton.Parent = frame

            rowButton.MouseButton1Click:Connect(function()
                if rowCallback then
                    rowCallback()
                end
            end)

            -- Dedicated switch hitbox. It stays visually on top of Fluent's switch
            -- but only toggles the Value; it never expands/collapses the group.
            local switchButton = Instance.new("TextButton")
            switchButton.Name = "qtieqToggleSwitchButton"
            switchButton.BackgroundTransparency = 1
            switchButton.BorderSizePixel = 0
            switchButton.AutoButtonColor = false
            switchButton.Text = ""
            switchButton.TextTransparency = 1
            switchButton.Size = UDim2.fromOffset(62, 36)
            switchButton.Position = UDim2.new(1, -62, 0.5, -18)
            switchButton.ZIndex = 200
            switchButton.Parent = frame

            switchButton.MouseButton1Click:Connect(function()
                pcall(function()
                    toggle:SetValue(not toggle.Value)
                end)
            end)
        end)
    end

    -- DROPDOWN INTERACTION
    -- Only the [▼] area is allowed to open/close a dropdown.
    -- Clicking the dropdown text/empty area does nothing.
    -- Dropdown popups are handled by FluentPlus outside the window so they
    -- stay at the right edge and are vertically centered.
    -- The popup scroll position is also preserved instead of snapping back to 0.
    local function restoreDropdownScroll(dropdown)
        task.defer(function()
            pcall(function()
                if not Fluent.GUI then
                    return
                end

                local popupFrame
                local popupScroll
                for _, guiChild in ipairs(Fluent.GUI:GetChildren()) do
                    -- FluentPlus creates each dropdown popup as a direct Frame
                    -- under Fluent.GUI. Do not require the original 300px height
                    -- here because we resize the popup to match the actual UI.
                    if guiChild:IsA("Frame") and guiChild.Visible and guiChild.Size.X.Offset == 170 then
                        local candidateScroll = guiChild:FindFirstChildWhichIsA("ScrollingFrame", true)
                        if candidateScroll then
                            popupFrame = guiChild
                            popupScroll = candidateScroll
                            break
                        end
                    end
                end

                if not popupFrame or not popupScroll then
                    return
                end

                -- Keep the dropdown window exactly as tall as the visible UI.
                -- This is especially important on mobile, where the main window
                -- may be reduced by UIScale while FluentPlus' popup is not.
                local windowFrame
                for _, guiChild in ipairs(Fluent.GUI:GetDescendants()) do
                    if guiChild:IsA("Frame")
                        and guiChild ~= popupFrame
                        and guiChild.Size.X.Offset == 500
                        and guiChild.Size.Y.Offset == 300 then
                        windowFrame = guiChild
                        break
                    end
                end

                if windowFrame then
                    local targetHeight = math.max(1, math.floor(windowFrame.AbsoluteSize.Y + 0.5))
                    popupFrame.Size = UDim2.fromOffset(170, targetHeight)

                    -- Re-center it beside the UI using the same rendered dimensions.
                    local targetX = windowFrame.AbsolutePosition.X + windowFrame.AbsoluteSize.X + 5
                    local targetY = windowFrame.AbsolutePosition.Y + (windowFrame.AbsoluteSize.Y - targetHeight) / 2
                    popupFrame.Position = UDim2.fromOffset(math.floor(targetX + 0.5), math.floor(targetY + 0.5))
                end

                -- No elastic bounce: when the user reaches the end, it stays there.
                popupScroll.ElasticBehavior = Enum.ElasticBehavior.Never
                popupScroll.Active = true
                popupScroll.ScrollingEnabled = true
                popupScroll.ScrollingDirection = Enum.ScrollingDirection.Y

                if dropdown.__qtieqScrollConnection then
                    dropdown.__qtieqScrollConnection:Disconnect()
                    dropdown.__qtieqScrollConnection = nil
                end

                dropdown.__qtieqScrollConnection = popupScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                    dropdown.__qtieqScrollPosition = popupScroll.CanvasPosition
                end)

                if dropdown.__qtieqScrollPosition then
                    local saved = dropdown.__qtieqScrollPosition
                    task.defer(function()
                        if popupScroll and popupScroll.Parent then
                            popupScroll.CanvasPosition = saved
                        end
                    end)
                    task.wait()
                    if popupScroll and popupScroll.Parent then
                        popupScroll.CanvasPosition = saved
                    end
                end
            end)
        end)
    end

    local function setupDropdownInteraction(dropdown)
        task.defer(function()
            if not dropdown or not dropdown.Elements or not dropdown.Elements.Frame then
                return
            end

            local frame = dropdown.Elements.Frame
            local dropdownInner = nil

            -- FluentPlus creates the dropdown's clickable area as the only
            -- direct TextButton inside the dropdown element.
            for _, child in ipairs(frame:GetChildren()) do
                if child:IsA("TextButton") then
                    dropdownInner = child
                    break
                end
            end

            if not dropdownInner then
                return
            end

            local oldBlocker = frame:FindFirstChild("qtieqDropdownTextBlocker")
            if oldBlocker then
                oldBlocker:Destroy()
            end

            local oldArrowButton = frame:FindFirstChild("qtieqDropdownArrowButton")
            if oldArrowButton then
                oldArrowButton:Destroy()
            end

            -- Block the normal full-width FluentPlus click area.
            -- The rightmost 28px is left free for the [▼] button.
            local textBlocker = Instance.new("TextButton")
            textBlocker.Name = "qtieqDropdownTextBlocker"
            textBlocker.BackgroundTransparency = 1
            textBlocker.BorderSizePixel = 0
            textBlocker.AutoButtonColor = false
            textBlocker.Text = ""
            textBlocker.TextTransparency = 1
            textBlocker.Size = UDim2.new(1, -28, 1, 0)
            textBlocker.Position = UDim2.fromOffset(0, 0)
            textBlocker.ZIndex = 250
            textBlocker.Parent = dropdownInner

            -- Dedicated [▼] hitbox. This is the ONLY place that opens/closes it.
            local arrowButton = Instance.new("TextButton")
            arrowButton.Name = "qtieqDropdownArrowButton"
            arrowButton.BackgroundTransparency = 1
            arrowButton.BorderSizePixel = 0
            arrowButton.AutoButtonColor = false
            arrowButton.Text = ""
            arrowButton.TextTransparency = 1
            arrowButton.Size = UDim2.fromOffset(28, 30)
            arrowButton.Position = UDim2.new(1, -28, 0.5, -15)
            arrowButton.ZIndex = 251
            arrowButton.Parent = dropdownInner

            arrowButton.Activated:Connect(function()
                pcall(function()
                    if dropdown.Opened then
                        dropdown:Close()
                    else
                        dropdown:Open()
                        -- Wait until FluentPlus creates/shows the popup, then
                        -- restore its last scroll position and disable bounce.
                        restoreDropdownScroll(dropdown)
                        task.delay(0.05, function()
                            restoreDropdownScroll(dropdown)
                        end)
                    end
                end)
            end)
        end)
    end

    local function addCollapseArrow(mainToggle, children, title)
        task.defer(function()
            if not mainToggle or not mainToggle.Elements or not mainToggle.Elements.Frame then
                return
            end

            local frame = mainToggle.Elements.Frame
            local labelHolder = mainToggle.Elements.LabelHolder
            local titleLabel = mainToggle.Elements.TitleLabel

            local oldArrow = frame:FindFirstChild("qtieqCollapseArrow")
            if oldArrow then
                oldArrow:Destroy()
            end

            if labelHolder then
                labelHolder.Position = UDim2.fromOffset(38, 0)
                labelHolder.Size = UDim2.new(1, -66, 0, 0)
            end

            -- Chevron: collapsed = >, expanded = v.
            local arrow = Instance.new("ImageLabel")
            arrow.Name = "qtieqCollapseArrow"
            arrow.BackgroundTransparency = 1
            arrow.BorderSizePixel = 0
            arrow.Active = false
            arrow.Visible = true
            arrow.Image = "rbxassetid://10709790948"
            arrow.ImageColor3 = Color3.fromRGB(170, 220, 255)
            arrow.ImageTransparency = 0
            arrow.Size = UDim2.fromOffset(20, 20)
            arrow.Position = UDim2.new(0, 8, 0.5, 0)
            arrow.AnchorPoint = Vector2.new(0, 0.5)
            arrow.Rotation = 270
            arrow.ZIndex = 100
            arrow.Parent = frame

            if titleLabel then
                titleLabel.Text = title
            end

            local expanded = false

            local function refresh()
                arrow.Rotation = expanded and 0 or 270
                for _, child in ipairs(children) do
                    setControlVisible(child, expanded)
                end

            end

            -- Clicking the row (anywhere except the dedicated switch) only expands
            -- or collapses the child menu. It does NOT change ON/OFF.
            setupToggleInteraction(mainToggle, function()
                expanded = not expanded
                refresh()
            end)

            -- Start collapsed.
            refresh()
        end)
    end


    local AutoTower = Tabs.Tower:AddToggle("AutoTower", {
        Title = "ลงหอคอยอัตโนมัติ",
        Default = false
    })

    AutoTower:OnChanged(function(Value)
        if Value and getgenv().autoRebirthEnabled and isRebirthLimitReached() then
            getgenv().autoTowerEnabled = false
            pcall(function()
                AutoTower:SetValue(false)
            end)
            return
        end

        getgenv().autoTowerEnabled = Value

        if Value and remotesModule then
            pcall(hookTowerContinueOffer)
        end

        if Value and not getgenv().autoTowerLoopActive and remotesModule then
            getgenv().autoTowerLoopActive = true

            task.spawn(function()
                while getgenv().autoTowerEnabled do
                    -- UFO has priority: keep the Toggle ON, but pause Tower completely.
                    if getgenv().ufoPriorityActive or getgenv().ufoPriorityTransitioning then
                        task.wait(0.1)
                        continue
                    end

                    if getgenv().autoRebirthEnabled and isRebirthLimitReached() then
                        disableTowerRebirthAtLimit()
                        break
                    end

                    -- หลัง Rebirth ต้องรอ 1 วิให้ครบก่อน
                    -- จากนั้น Auto Tower จะเริ่มนับ Tower Delay ใหม่
                    if getgenv().autoTowerWaitingAfterRebirth then
                        task.wait(0.1)
                    elseif getgenv().autoRebirthEnabled and isRebirthPending() then
                        -- Only Auto Rebirth may react to a ready Rebirth.
                        task.wait(0.1)
                    elseif isTowerRunActive() then
                        task.wait(1)
                    else
                        -- Tower is inactive and Rebirth is not pending:
                        -- wait the configured delay, then start the next Tower.
                        local towerDelay = tonumber(getgenv().towerDelaySeconds) or 5
                        towerDelay = math.clamp(towerDelay, 1, 60)

                        local delayStart = os.clock()

                        while getgenv().autoTowerEnabled
                            and not getgenv().ufoPriorityActive
                            and not getgenv().ufoPriorityTransitioning
                            and os.clock() - delayStart < towerDelay do
                            if (getgenv().autoRebirthEnabled and isRebirthLimitReached()) or isTowerRunActive() or (getgenv().autoRebirthEnabled and isRebirthPending()) then
                                break
                            end

                            task.wait(0.1)
                        end

                        if getgenv().autoTowerEnabled
                            and not getgenv().ufoPriorityActive
                            and not getgenv().ufoPriorityTransitioning
                            and not (getgenv().autoRebirthEnabled and isRebirthLimitReached())
                            and not isTowerRunActive()
                            and not (getgenv().autoRebirthEnabled and isRebirthPending())
                            and os.clock() - delayStart >= towerDelay then
                            pcall(startTowerRun)
                        end

                        task.wait(1)
                    end
                end

                getgenv().autoTowerLoopActive = false
            end)
        end
    end)

    local TowerDelayInput = Tabs.Tower:AddInput("TowerDelayInput", {
        Title = "ดีเลย์ก่อนลงหอคอย",
        Default = "5",
        Placeholder = "เช่น 15",
        Numeric = true,
        Finished = true,
        Callback = function(Value)
            local number = tonumber(Value)

            if number then
                getgenv().towerDelaySeconds = math.clamp(math.floor(number), 1, 60)

            end
        end
    })

    local LastTower = Tabs.Tower:AddToggle("LastTower", {
        Title = "ลงหอคอยชั้นล่าสุด",
        Default = false
    })

    LastTower:OnChanged(function(Value)
        getgenv().autoTowerLastFloorEnabled = Value
    end)

    local AutoRebirth = Tabs.Tower:AddToggle("AutoRebirth", {
        Title = "รีเบิร์ธอัตโนมัติ",
        Default = false
    })

    AutoRebirth:OnChanged(function(Value)
        -- Rebirth Limit belongs to Auto Rebirth. Auto Tower alone ignores it.
        if Value and isRebirthLimitReached() then
            getgenv().autoRebirthEnabled = false
            pcall(function()
                AutoRebirth:SetValue(false)
            end)
            return
        end

        getgenv().autoRebirthEnabled = Value

        if Value and not getgenv().autoRebirthLoopActive and remotesModule and rebirthBonusModule and rebirthExperimentModule and dataControllerModule then
            getgenv().autoRebirthLoopActive = true

            task.spawn(function()
                while getgenv().autoRebirthEnabled do
                    -- Rebirth Limit has absolute priority: stop both Tower and Rebirth
                    -- as soon as the current rebirth count reaches the configured limit.
                    if isRebirthLimitReached() then
                        disableTowerRebirthAtLimit()
                        break
                    end

                    -- UFO has priority: keep Rebirth enabled, but do not start/rebirth during UFO.
                    if getgenv().ufoPriorityActive or getgenv().ufoPriorityTransitioning then
                        task.wait(0.1)
                        continue
                    end

                    local readySuccess, isReady = pcall(isRebirthReady)

                    if readySuccess and isReady and not getgenv().ufoPriorityActive and not getgenv().ufoPriorityTransitioning then
                        -- Rebirth ready: send TowerSurrender first, without relying on TowerActive.
                        pcall(function()
                            remotesModule.invoke(remotesModule.defs.TowerSurrender)
                        end)

                        task.wait(0.5)

                        local waitStart = os.clock()
                        while isTowerRunActive() and os.clock() - waitStart < 5 do
                            task.wait(0.1)
                        end

                        local fireSuccess, fireResult = false, false
                        -- Check the limit again immediately before the actual Rebirth remote.
                        -- This prevents a race where the count reaches the limit between
                        -- the loop-start check and the Rebirth request.
                        if not isRebirthLimitReached()
                            and not getgenv().ufoPriorityActive
                            and not getgenv().ufoPriorityTransitioning then
                            fireSuccess, fireResult = pcall(requestRebirth)
                        end

                        if fireSuccess and fireResult and not getgenv().ufoPriorityActive and not getgenv().ufoPriorityTransitioning then
                            -- Rebirth สำเร็จ: รอ 1 วินาทีก่อน
                            -- แล้วค่อยเริ่มนับ Tower Delay ที่ตั้งไว้
                            getgenv().autoTowerWaitingAfterRebirth = true
                            task.wait(1)
                            getgenv().autoTowerWaitingAfterRebirth = false
                        end
                    end

                    task.wait(1)
                end

                getgenv().autoRebirthLoopActive = false
            end)
        end
    end)

    local RebirthLimitInput = Tabs.Tower:AddInput("RebirthLimitInput", {
        Title = "ระบุจำนวน Rebirth",
        Description = "0=ไม่จำกัด",
        Default = "0",
        Placeholder = "เช่น 1000",
        Numeric = true,
        Finished = true,
        Callback = function(Value)
            local number = tonumber(Value)
            if number then
                getgenv().rebirthLimit = math.clamp(math.floor(number), 0, 20000)
            end
        end
    })

    local AutoUFO = Tabs.Events:AddToggle("AutoUFO", {
        Title = "ลง UFO อัตโนมัติ",
        Default = false
    })

    AutoUFO:OnChanged(function(Value)
        autoUFORunning = Value

        if Value then
            -- The UFO chicken list is refreshed only by the manual refresh button.
            startAutoUFOLoop()
        else
            ufoEventActive = false
            ufoSequenceRunning = false
            ufoEndHandled = false
            resetUFOOriginalChicken()
            setUFOPriorityActive(false)
        end
    end)

    ufoChickenDropdown = Tabs.Events:AddDropdown("UFOChickenDropdown", {
        Title = "เลือกไก่",
        Values = {},
        Multi = false,
        Default = nil,
        Callback = function(value)
            ufoSelectedChickenId = ufoChickenOptionToId[value]
        end
    })

    setupDropdownInteraction(ufoChickenDropdown)

    ufoChickenRefreshButton = Tabs.Events:AddButton({
        Title = "กดเพื่ออัพเดทไก่ในกระเป๋า",
        Callback = function()
            refreshUFOChickenList()
        end
    })

    local AutoBuyFeeder = Tabs.Upgrades:AddToggle("AutoBuyFeeder", {
        Title = "ซื้อที่ให้อาหาร",
        Default = false
    })

    AutoBuyFeeder:OnChanged(function(Value)
        getgenv().autoBuyFeederEnabled = Value

        if Value and not getgenv().autoBuyFeederLoopActive and remotesModule and coopViewModule and dataServiceModule and dataControllerModule then
            getgenv().autoBuyFeederLoopActive = true

            task.spawn(function()
                while getgenv().autoBuyFeederEnabled do
                    pcall(buyFeeder)

                    task.wait(1)
                end

                getgenv().autoBuyFeederLoopActive = false
            end)
        end
    end)

    local AutoUpgradeFeeder = Tabs.Upgrades:AddToggle("AutoUpgradeFeeder", {
        Title = "อัพที่ให้อาหาร",
        Default = false
    })

    AutoUpgradeFeeder:OnChanged(function(Value)
        getgenv().autoUpgradeFeederEnabled = Value

        if Value and not getgenv().autoUpgradeFeederLoopActive and remotesModule and coopViewModule and dataServiceModule and dataControllerModule then
            getgenv().autoUpgradeFeederLoopActive = true

            task.spawn(function()
                while getgenv().autoUpgradeFeederEnabled do
                    pcall(upgradeFeeders)

                    task.wait(1)
                end

                getgenv().autoUpgradeFeederLoopActive = false
            end)
        end
    end)

    local AutoUpgradeCoop = Tabs.Upgrades:AddToggle("AutoUpgradeCoop", {
        Title = "ขยายบ้าน",
        Default = false
    })

    AutoUpgradeCoop:OnChanged(function(Value)
        getgenv().autoUpgradeCoopEnabled = Value

        if Value and not getgenv().autoUpgradeCoopLoopActive and remotesModule and coopViewModule and dataServiceModule and dataControllerModule then
            getgenv().autoUpgradeCoopLoopActive = true

            task.spawn(function()
                while getgenv().autoUpgradeCoopEnabled do
                    pcall(upgradeCoop)

                    task.wait(5)
                end

                getgenv().autoUpgradeCoopLoopActive = false
            end)
        end
    end)

    local AutoUpgradeRecycler = Tabs.Upgrades:AddToggle("AutoUpgradeRecycler", {
        Title = "อัพถังรีไซเคิล",
        Default = false
    })

    AutoUpgradeRecycler:OnChanged(function(Value)
        getgenv().autoUpgradeRecyclerEnabled = Value

        if Value and not getgenv().autoUpgradeRecyclerLoopActive and remotesModule and recyclerViewModule and dataServiceModule and dataControllerModule then
            getgenv().autoUpgradeRecyclerLoopActive = true

            task.spawn(function()
                while getgenv().autoUpgradeRecyclerEnabled do
                    pcall(upgradeRecycler)

                    task.wait(2)
                end

                getgenv().autoUpgradeRecyclerLoopActive = false
            end)
        end
    end)

    local AutoCollectEgg = Tabs.Farm:AddToggle("AutoCollectEgg", {
        Title = "เก็บไข่อัตโนมัติ",
        Default = false
    })

    AutoCollectEgg:OnChanged(function(Value)
        getgenv().autoCollectEggEnabled = Value

        if Value and not getgenv().autoCollectEggLoopActive then
            getgenv().autoCollectEggLoopActive = true

            task.spawn(function()
                while getgenv().autoCollectEggEnabled do
                    local playerCharacter = localPlayer.Character
                    local playerHumanoid = playerCharacter and playerCharacter:FindFirstChildOfClass("Humanoid")

                    if playerHumanoid and playerHumanoid.Health > 0 then
                        -- Standstill: do not MoveTo the egg. Trigger the egg's normal
                        -- touch pickup directly from the player's current position.
                        local ownedEggs = getOwnedEggs()

                        for _, eggInstance in ipairs(ownedEggs) do
                            if not getgenv().autoCollectEggEnabled then
                                break
                            end

                            collectEggStandstill(eggInstance)
                        end
                    end

                    task.wait(1)
                end

                getgenv().autoCollectEggLoopActive = false
            end)
        end
    end)


    -- AUTO HOT EGG
    -- Normal event system: no Tower/Rebirth priority and no remote is fired for the egg.
    -- HOT EGG start/end is detected from the game's HotEgg remotes, with
    -- LiveEventGetActive used as an additional state check when its payload exposes
    -- a HOT EGG identifier.
    local hotEggEventActive = false
    local hotEggLastEventCheck = 0
    local hotEggRemoteHooksInstalled = false

    local function valueSaysHotEgg(value, depth, seen)
        depth = depth or 0
        seen = seen or {}

        if depth > 5 then
            return false
        end

        local valueType = typeof(value)

        if valueType == "string" then
            local text = string.lower(value):gsub("%s+", "")
            return text:find("hotegg", 1, true) ~= nil
                or text:find("blazingegg", 1, true) ~= nil
        end

        if valueType ~= "table" then
            return false
        end

        if seen[value] then
            return false
        end

        seen[value] = true

        for k, v in pairs(value) do
            if valueSaysHotEgg(k, depth + 1, seen) or valueSaysHotEgg(v, depth + 1, seen) then
                return true
            end
        end

        return false
    end

    local function queryLiveEventForHotEgg()
        local remotes = replicatedStorage:FindFirstChild("Remotes")
        local liveRemote = remotes and remotes:FindFirstChild("LiveEventGetActive")

        if not liveRemote or not liveRemote:IsA("RemoteFunction") then
            return nil
        end

        local ok, result = pcall(function()
            return liveRemote:InvokeServer()
        end)

        if not ok then
            return nil
        end

        return valueSaysHotEgg(result)
    end

    local function isHotEggObject(instance)
        if not instance then
            return false
        end

        local lowerName = string.lower(instance.Name):gsub("%s+", "")

        if lowerName:find("blazingegg", 1, true) ~= nil
            or lowerName:find("hotegg", 1, true) ~= nil then
            return true
        end

        -- Some game objects expose the egg name through an attribute instead of
        -- putting it directly in Instance.Name.
        for _, attributeName in ipairs({ "EggName", "eggName", "Egg", "egg" }) do
            local ok, value = pcall(function()
                return instance:GetAttribute(attributeName)
            end)

            if ok and typeof(value) == "string" then
                local text = string.lower(value):gsub("%s+", "")
                if text:find("blazingegg", 1, true) ~= nil
                    or text:find("hotegg", 1, true) ~= nil then
                    return true
                end
            end
        end

        return false
    end

    local function getInstancePosition(instance)
        if instance:IsA("BasePart") then
            return instance.Position
        end

        if instance:IsA("Model") then
            return instance:GetPivot().Position
        end

        local part = instance:FindFirstChildWhichIsA("BasePart", true)
        return part and part.Position or nil
    end

    local function isHoldingHotEgg()
        local character = localPlayer.Character
        local head = character and character:FindFirstChild("Head")

        if not head then
            return false
        end

        for _, instance in ipairs(head:GetDescendants()) do
            if isHotEggObject(instance) then
                return true
            end
        end

        return false
    end

    local function findBlazingEgg()
        -- Fast path: exact names first.
        for _, name in ipairs({ "BlazingEgg", "Blazing Egg", "HotEgg", "Hot Egg" }) do
            local exact = workspace:FindFirstChild(name, true)
            if exact and isHotEggObject(exact) then
                local position = getInstancePosition(exact)
                if position then
                    return exact, position
                end
            end
        end

        -- Fallback: scan the live workspace for a named HOT/Blazing egg.
        for _, instance in ipairs(workspace:GetDescendants()) do
            if isHotEggObject(instance) then
                local position = getInstancePosition(instance)
                if position then
                    return instance, position
                end
            end
        end

        return nil, nil
    end

    local function getArenaFloor()
        for _, instance in ipairs(workspace:GetDescendants()) do
            if instance:IsA("BasePart") and instance:GetAttribute("ArenaFloor") == true then
                return instance
            end
        end

        return nil
    end

    local function getNearestArenaEdgePosition(rootPosition)
        local floor = getArenaFloor()

        local centerX = floor and floor.Position.X or 0
        local centerZ = floor and floor.Position.Z or 0

        -- Central arena is 80x80. Stand slightly inside the boundary.
        local edge = 38
        local minX = centerX - edge
        local maxX = centerX + edge
        local minZ = centerZ - edge
        local maxZ = centerZ + edge

        local candidates = {
            Vector3.new(minX, rootPosition.Y, math.clamp(rootPosition.Z, minZ, maxZ)),
            Vector3.new(maxX, rootPosition.Y, math.clamp(rootPosition.Z, minZ, maxZ)),
            Vector3.new(math.clamp(rootPosition.X, minX, maxX), rootPosition.Y, minZ),
            Vector3.new(math.clamp(rootPosition.X, minX, maxX), rootPosition.Y, maxZ),
        }

        local nearest = candidates[1]
        local nearestDistance = (rootPosition - nearest).Magnitude

        for i = 2, #candidates do
            local distance = (rootPosition - candidates[i]).Magnitude
            if distance < nearestDistance then
                nearest = candidates[i]
                nearestDistance = distance
            end
        end

        return nearest
    end

    local function moveHotEggCharacterTo(humanoid, targetPosition, timeout)
        if not humanoid or not targetPosition then
            return false
        end

        local started = os.clock()
        humanoid:MoveTo(targetPosition)

        while getgenv().autoHotEggEnabled and hotEggEventActive do
            local character = localPlayer.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")

            if not root or humanoid.Health <= 0 then
                return false
            end

            if (root.Position - targetPosition).Magnitude <= 3.5 then
                return true
            end

            if timeout and os.clock() - started >= timeout then
                return false
            end

            task.wait(0.15)
            humanoid:MoveTo(targetPosition)
        end

        return false
    end

    local function finishHotEggEvent()
        hotEggEventActive = false
    end

    local function startHotEggEvent()
        hotEggEventActive = true
    end

    local function hookHotEggEventRemotes()
        if hotEggRemoteHooksInstalled then
            return
        end

        local remotes = replicatedStorage:FindFirstChild("Remotes")
        if not remotes then
            return
        end

        local entrance = remotes:FindFirstChild("HotEggEntrance")
        if entrance and entrance:IsA("RemoteEvent") then
            entrance:SetAttribute("qtieqHotEggHooked", true)
            entrance.OnClientEvent:Connect(function()
                if getgenv().autoHotEggEnabled then
                    startHotEggEvent()
                end
            end)
        end

        local finale = remotes:FindFirstChild("HotEggFinale")
        if finale and finale:IsA("RemoteEvent") then
            finale:SetAttribute("qtieqHotEggHooked", true)
            finale.OnClientEvent:Connect(function()
                if getgenv().autoHotEggEnabled then
                    finishHotEggEvent()
                end
            end)
        end

        -- Keep the same LiveEvent signal style used by UFO as a fallback.
        local function hookLiveSignal(name, isEnd)
            local remote = remotes:FindFirstChild(name)
            if not remote or not remote:IsA("RemoteEvent") then
                return
            end

            local attr = "qtieqHotEggLiveHooked_" .. name
            if remote:GetAttribute(attr) then
                return
            end

            remote:SetAttribute(attr, true)
            remote.OnClientEvent:Connect(function(...)
                if not getgenv().autoHotEggEnabled then
                    return
                end

                if isEnd then
                    if valueSaysHotEgg(...) then
                        finishHotEggEvent()
                    end
                elseif valueSaysHotEgg(...) then
                    startHotEggEvent()
                end
            end)
        end

        for _, name in ipairs({
            "LiveEventStarted",
            "LiveEventStateChanged",
            "LiveEventClientSignal",
            "LiveEventSignal",
            "LiveEventResumed",
        }) do
            hookLiveSignal(name, false)
        end

        hookLiveSignal("LiveEventEnded", true)

        hotEggRemoteHooksInstalled = true
    end

    local function startAutoHotEggLoop()
        if getgenv().autoHotEggLoopActive then
            return
        end

        hookHotEggEventRemotes()
        getgenv().autoHotEggLoopActive = true

        task.spawn(function()
            while getgenv().autoHotEggEnabled do
                hookHotEggEventRemotes()

                -- Same state-query idea as UFO, but matching HOT EGG instead.
                if os.clock() - hotEggLastEventCheck >= 0.75 then
                    hotEggLastEventCheck = os.clock()

                    local activeSaysHotEgg = queryLiveEventForHotEgg()
                    -- Only a positive HOT EGG result is allowed to start the loop.
                    -- A false/unknown result is not treated as an end signal because
                    -- HotEggFinale is the authoritative HOT EGG end signal.
                    if activeSaysHotEgg == true then
                        hotEggEventActive = true
                    end
                end

                if hotEggEventActive then
                    local character = localPlayer.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    local root = character and character:FindFirstChild("HumanoidRootPart")

                    if humanoid and root and humanoid.Health > 0 then
                        if not isHoldingHotEgg() then
                            local _, eggPosition = findBlazingEgg()

                            if eggPosition then
                                -- Walk into the egg so the normal game touch/pickup
                                -- behavior puts it on the player's head.
                                moveHotEggCharacterTo(humanoid, eggPosition, 10)
                            end
                        else
                            local edgePosition = getNearestArenaEdgePosition(root.Position)

                            if edgePosition then
                                -- Move to the nearest edge, then stay there while the
                                -- egg is still attached. After a meteor drops it,
                                -- isHoldingHotEgg() becomes false and the loop goes
                                -- back to find and pick it up again.
                                moveHotEggCharacterTo(humanoid, edgePosition, 8)

                                while getgenv().autoHotEggEnabled
                                    and hotEggEventActive
                                    and isHoldingHotEgg() do

                                    local currentCharacter = localPlayer.Character
                                    local currentHumanoid = currentCharacter
                                        and currentCharacter:FindFirstChildOfClass("Humanoid")
                                    local currentRoot = currentCharacter
                                        and currentCharacter:FindFirstChild("HumanoidRootPart")

                                    if not currentHumanoid or not currentRoot or currentHumanoid.Health <= 0 then
                                        break
                                    end

                                    local currentEdgePosition = getNearestArenaEdgePosition(currentRoot.Position)

                                    if currentEdgePosition
                                        and (currentRoot.Position - currentEdgePosition).Magnitude > 3 then
                                        currentHumanoid:MoveTo(currentEdgePosition)
                                    end

                                    task.wait(0.25)
                                end
                            end
                        end
                    end
                end

                task.wait(0.2)
            end

            hotEggEventActive = false
            getgenv().autoHotEggLoopActive = false
        end)
    end

    local AutoHotEgg = Tabs.Events:AddToggle("AutoHotEgg", {
        Title = "เก็บไข่ร้อนอัตโนมัติ",
        Default = false
    })

    AutoHotEgg:OnChanged(function(Value)
        getgenv().autoHotEggEnabled = Value

        if not Value then
            hotEggEventActive = false
            return
        end

        startAutoHotEggLoop()
    end)

    -- AUTO PROMOTE
    -- Target chickens are tracked by their unique inventory id, so chickens with
    -- the same name but different stars (or even identical name/star) remain separate.
    local autoPromoteChildren = {}
    local autoPromoteRefreshButton = nil
    local autoPromoteToggle = nil
    local autoPromoteChickenDropdown = nil
    local autoPromoteRefreshing = false
    local autoPromoteOptionToId = {}

    local function getChickenDisplayName(chicken)
        local typeId = chicken and chicken.typeId
        if localeModule and typeId then
            local ok, name = pcall(function()
                return localeModule.chicken(typeId)
            end)
            if ok and type(name) == "string" and name ~= "" then
                return name
            end
        end

        return tostring(typeId or "Unknown Chicken")
    end

    local function getPromotionRoster()
        if not dataControllerModule then
            return nil
        end

        local ok, roster = pcall(function()
            return dataControllerModule.roster()
        end)

        if not ok or type(roster) ~= "table" or type(roster.chickens) ~= "table" then
            return nil
        end

        return roster
    end

    local function getPromotionStars(chicken)
        if promotionViewModule and promotionViewModule.stars then
            local ok, stars = pcall(function()
                return promotionViewModule.stars(chicken)
            end)
            if ok then
                return tonumber(stars) or 0
            end
        end

        return math.clamp(math.floor(tonumber(chicken and chicken.promo) or 0), 0, 10)
    end

    local function getPromotionProgress(chicken)
        if promotionViewModule and promotionViewModule.progress then
            local ok, progress = pcall(function()
                return promotionViewModule.progress(chicken)
            end)
            if ok and type(progress) == "table" then
                return progress
            end
        end

        return {
            stars = getPromotionStars(chicken),
            dupes = math.max(0, math.floor(tonumber(chicken and chicken.promoDupes) or 0)),
            need = nil,
            atCap = getPromotionStars(chicken) >= 10
        }
    end

    local function refreshAutoPromoteList()
        if autoPromoteRefreshing then
            return
        end

        autoPromoteRefreshing = true
        autoPromoteOptionToId = {}

        local roster = getPromotionRoster()
        if not roster then
            if autoPromoteChickenDropdown then
                pcall(function()
                    autoPromoteChickenDropdown:SetValues({})
                end)
            end
            autoPromoteRefreshing = false
            return
        end

        local options = {}
        local liveIds = {}
        local chickens = table.clone(roster.chickens or {})

        -- Keep the exact order supplied by the game's roster/inventory data.
        -- Do not alphabetically sort the chicken list.
        for _, chicken in ipairs(chickens) do
            if chicken and chicken.id ~= nil then
                local id = tostring(chicken.id)
                liveIds[id] = true

                local stars = getPromotionStars(chicken)
                local option = string.format("%s ★%d [%s]", getChickenDisplayName(chicken), stars, id)
                autoPromoteOptionToId[option] = id
                table.insert(options, option)
            end
        end

        for id in pairs(getgenv().autoPromoteSelected) do
            if not liveIds[tostring(id)] then
                getgenv().autoPromoteSelected[id] = nil
            end
        end

        if autoPromoteChickenDropdown then
            pcall(function()
                autoPromoteChickenDropdown:SetValues(options)

                local selectedOptions = {}
                for option, id in pairs(autoPromoteOptionToId) do
                    if getgenv().autoPromoteSelected[id] == true then
                        table.insert(selectedOptions, option)
                    end
                end

                autoPromoteChickenDropdown:SetValue(selectedOptions)
            end)
        end

        autoPromoteRefreshing = false
    end

    local function isAutoPromoteTargetSelected(id)
        return getgenv().autoPromoteSelected[tostring(id)] == true
    end

    local function isEligiblePromotionDupe(dupe, target, roster)
        if not dupe or not target or dupe.id == target.id then
            return false
        end

        if dupe.typeId ~= target.typeId then
            return false
        end

        if dupe.favorite == true then
            return false
        end

        if roster and dupe.id == roster.activeId then
            return false
        end

        -- Never consume another chicken the user explicitly selected as an Auto Promote target.
        if isAutoPromoteTargetSelected(dupe.id) then
            return false
        end

        return true
    end

    local function buildPromotionDupes(target, roster, needed)
        local candidates = {}

        for _, chicken in ipairs(roster.chickens or {}) do
            if isEligiblePromotionDupe(chicken, target, roster) then
                table.insert(candidates, chicken)
            end
        end

        table.sort(candidates, function(a, b)
            local aProgress = getPromotionProgress(a)
            local bProgress = getPromotionProgress(b)
            local aInvested = (tonumber(aProgress.stars) or 0) + (tonumber(aProgress.dupes) or 0)
            local bInvested = (tonumber(bProgress.stars) or 0) + (tonumber(bProgress.dupes) or 0)

            if aInvested ~= bInvested then
                return aInvested < bInvested
            end

            return tostring(a.id or "") < tostring(b.id or "")
        end)

        local ids = {}
        for _, chicken in ipairs(candidates) do
            if #ids >= needed then
                break
            end
            table.insert(ids, chicken.id)
        end

        return ids
    end

    local function promoteOneSelectedChicken()
        local roster = getPromotionRoster()
        if not roster or not remotesModule or not remotesModule.defs or not remotesModule.defs.PromoteChicken then
            return false
        end

        for _, target in ipairs(roster.chickens or {}) do
            if target and target.id ~= nil and isAutoPromoteTargetSelected(target.id) then
                local progress = getPromotionProgress(target)

                if not progress.atCap and progress.need ~= nil then
                    local need = math.max(0, math.floor(tonumber(progress.need) or 0))
                    local dupes = math.max(0, math.floor(tonumber(progress.dupes) or 0))
                    local missing = math.max(0, need - dupes)

                    if missing <= 0 then
                        local result = remotesModule.invoke(remotesModule.defs.PromoteChicken, target.id, {})
                        if typeof(result) == "table" and result.ok then
                            task.wait(0.25)
                            return true
                        end
                    elseif missing > 0 then
                        local duplicateIds = buildPromotionDupes(target, roster, missing)
                        if #duplicateIds > 0 then
                            local result = remotesModule.invoke(remotesModule.defs.PromoteChicken, target.id, duplicateIds)
                            if typeof(result) == "table" and result.ok then
                                task.wait(0.25)
                                return true
                            end
                        end
                    end
                end
            end
        end

        return false
    end

    local function startAutoPromoteLoop()
        if getgenv().autoPromoteLoopActive then
            return
        end

        getgenv().autoPromoteLoopActive = true

        task.spawn(function()
            while getgenv().autoPromoteEnabled do
                local promoted = false
                pcall(function()
                    promoted = promoteOneSelectedChicken()
                end)

                if promoted then
                    task.wait(0.25)
                else
                    task.wait(1)
                end
            end

            getgenv().autoPromoteLoopActive = false
        end)
    end

    local AutoPromote = Tabs.Chicken:AddToggle("AutoPromote", {
        Title = "อัพดาวอัตโนมัติ",
        Default = false
    })
    autoPromoteToggle = AutoPromote

    AutoPromote:OnChanged(function(Value)
        getgenv().autoPromoteEnabled = Value == true

        if Value then
            startAutoPromoteLoop()
        end
    end)

    autoPromoteChickenDropdown = Tabs.Chicken:AddDropdown("AutoPromoteChickenDropdown", {
        Title = "ไก่ในกระเป๋า",
        Values = {},
        Multi = true,
        Default = {},
        Callback = function(values)
            table.clear(getgenv().autoPromoteSelected)

            if type(values) == "table" then
                for option, selected in pairs(values) do
                    if selected == true then
                        local id = autoPromoteOptionToId[option]
                        if id then
                            getgenv().autoPromoteSelected[id] = true
                        end
                    end
                end
            end
        end
    })

    setupDropdownInteraction(autoPromoteChickenDropdown)

    autoPromoteRefreshButton = Tabs.Chicken:AddButton({
        Title = "กดเพื่ออัพเดทไก่ในกระเป๋า",
        Callback = function()
            refreshAutoPromoteList()
        end
    })

    -- Keep the main Toggle as the collapse/expand control.
    table.insert(autoPromoteChildren, autoPromoteChickenDropdown)
    table.insert(autoPromoteChildren, autoPromoteRefreshButton)
    addCollapseArrow(AutoPromote, autoPromoteChildren, "อัพดาวอัตโนมัติ")
    -- Refresh the chicken Dropdown only when the manual refresh button is pressed.

    -- AUTO SELL
    -- Everything below belongs to the main "ขายไก่อัตโนมัติ" group.
    -- The three sub-groups can each be expanded/collapsed independently.

    local function normalizeAutoSellKey(value)
        if value == nil then
            return ""
        end
        return string.lower(tostring(value))
    end

    local function getAutoSellRarity(chicken)
        return normalizeAutoSellKey(chicken and chicken.rarity)
    end

    local function getAutoSellMutation(chicken)
        return normalizeAutoSellKey(chicken and chicken.mutation)
    end

    local function hasAutoSellRuleSelected()
        for _, selected in pairs(getgenv().autoSellSelectedRarities) do
            if selected == true then
                return true
            end
        end
        return false
    end

    local function shouldAutoSellChicken(chicken, roster)
        if not chicken or chicken.id == nil then
            return false
        end

        -- Favorites are already protected by the game.
        if chicken.favorite == true then
            return false
        end

        -- Never sell the currently active chicken.
        if roster and chicken.id == roster.activeId then
            return false
        end

        local rarity = getAutoSellRarity(chicken)
        if rarity == "" or getgenv().autoSellSelectedRarities[rarity] ~= true then
            return false
        end

        -- Keep-rarity has priority over sell-rarity.
        if getgenv().autoSellKeepRarities[rarity] == true then
            return false
        end

        -- Keep-status also has priority over selling.
        local mutation = getAutoSellMutation(chicken)
        if mutation ~= "" and getgenv().autoSellKeepMutations[mutation] == true then
            return false
        end

        return true
    end

    local function sellAutoSellMatches()
        if not getgenv().autoSellEnabled or not remotesModule then
            return false
        end

        -- If nothing is selected in "เลือกระดับที่จะขาย", sell nothing.
        if not hasAutoSellRuleSelected() then
            return false
        end

        local roster = getPromotionRoster()
        if not roster or type(roster.chickens) ~= "table" then
            return false
        end

        if not remotesModule.defs or not remotesModule.defs.SellChickens then
            return false
        end

        local ids = {}
        for _, chicken in ipairs(roster.chickens) do
            if shouldAutoSellChicken(chicken, roster) then
                table.insert(ids, chicken.id)
            end
        end

        if #ids == 0 then
            return false
        end

        local ok, result = pcall(function()
            return remotesModule.invoke(remotesModule.defs.SellChickens, ids)
        end)

        if not ok or typeof(result) ~= "table" or result.ok ~= true then
            return false
        end

        local soldCount = 0
        if type(result.data) == "table" then
            soldCount = tonumber(result.data.count) or 0
        end

        return soldCount > 0
    end

    local function startAutoSellLoop()
        if getgenv().autoSellLoopActive then
            return
        end

        getgenv().autoSellLoopActive = true

        task.spawn(function()
            while getgenv().autoSellEnabled do
                local sold = false
                pcall(function()
                    sold = sellAutoSellMatches()
                end)

                if sold then
                    task.wait(0.35)
                else
                    task.wait(0.75)
                end
            end

            getgenv().autoSellLoopActive = false
        end)
    end

    local AutoSell = Tabs.Chicken:AddToggle("AutoSell", {
        Title = "ขายไก่อัตโนมัติ",
        Default = false
    })

    AutoSell:OnChanged(function(Value)
        getgenv().autoSellEnabled = Value == true
        if Value then
            startAutoSellLoop()
        end
    end)

    local autoSellRarities = {
        {"Common", "common"},
        {"Uncommon", "uncommon"},
        {"Rare", "rare"},
        {"Epic", "epic"},
        {"Legendary", "legendary"},
        {"Mythic", "mythic"},
        {"Divine", "divine"},
        {"Celestial", "celestial"},
        {"Cosmic", "cosmic"},
        {"Secret", "secret"}
    }

    local autoSellStatuses = {
        {"Inverted", "inverted"},
        {"Jurassic", "jurassic"}
    }

    local sellRarityValues = {}
    local keepRarityValues = {}
    local keepStatusValues = {}

    for _, info in ipairs(autoSellRarities) do
        table.insert(sellRarityValues, info[1])
        table.insert(keepRarityValues, info[1])
    end

    for _, info in ipairs(autoSellStatuses) do
        table.insert(keepStatusValues, info[1])
    end

    local function buildSelectedLabels(values, selectedTable)
        local result = {}
        for _, label in ipairs(values) do
            local key = normalizeAutoSellKey(label)
            if selectedTable[key] == true then
                table.insert(result, label)
            end
        end
        return result
    end

    local AutoSellRarityDropdown = Tabs.Chicken:AddDropdown("AutoSellRarityDropdown", {
        Title = "เลือกระดับที่จะขาย",
        Values = sellRarityValues,
        Multi = true,
        Default = buildSelectedLabels(sellRarityValues, getgenv().autoSellSelectedRarities),
        Callback = function(values)
            table.clear(getgenv().autoSellSelectedRarities)
            if type(values) == "table" then
                for label, selected in pairs(values) do
                    if selected == true then
                        getgenv().autoSellSelectedRarities[normalizeAutoSellKey(label)] = true
                    end
                end
            end
        end
    })

    setupDropdownInteraction(AutoSellRarityDropdown)

    local AutoSellKeepRarityDropdown = Tabs.Chicken:AddDropdown("AutoSellKeepRarityDropdown", {
        Title = "เลือกระดับที่จะเก็บ",
        Values = keepRarityValues,
        Multi = true,
        Default = buildSelectedLabels(keepRarityValues, getgenv().autoSellKeepRarities),
        Callback = function(values)
            table.clear(getgenv().autoSellKeepRarities)
            if type(values) == "table" then
                for label, selected in pairs(values) do
                    if selected == true then
                        getgenv().autoSellKeepRarities[normalizeAutoSellKey(label)] = true
                    end
                end
            end
        end
    })

    setupDropdownInteraction(AutoSellKeepRarityDropdown)

    local AutoSellKeepStatusDropdown = Tabs.Chicken:AddDropdown("AutoSellKeepStatusDropdown", {
        Title = "เลือกสถานะที่จะเก็บ",
        Values = keepStatusValues,
        Multi = true,
        Default = buildSelectedLabels(keepStatusValues, getgenv().autoSellKeepMutations),
        Callback = function(values)
            table.clear(getgenv().autoSellKeepMutations)
            if type(values) == "table" then
                for label, selected in pairs(values) do
                    if selected == true then
                        getgenv().autoSellKeepMutations[normalizeAutoSellKey(label)] = true
                    end
                end
            end
        end
    })

    setupDropdownInteraction(AutoSellKeepStatusDropdown)

    -- The main Toggle remains the only collapse/expand control.
    autoSellChildren = {
        AutoSellRarityDropdown,
        AutoSellKeepRarityDropdown,
        AutoSellKeepStatusDropdown
    }

    addCollapseArrow(AutoSell, autoSellChildren, "ขายไก่อัตโนมัติ")

    -- AUTO PET
    getgenv().autoPetDelay = getgenv().autoPetDelay or 0.5

    local AutoPet = Tabs.Farm:AddToggle("AutoPet", {
        Title = "ลูบไก่อัตโนมัติ",
        Default = false
    })

    AutoPet:OnChanged(function(Value)
        getgenv().autoPetEnabled = Value

        if Value and not getgenv().autoPetLoopActive then
            getgenv().autoPetLoopActive = true

            task.spawn(function()
                while getgenv().autoPetEnabled do
                    if getgenv().ufoPriorityActive or getgenv().ufoPriorityTransitioning then
                        task.wait(0.1)
                        continue
                    end

                    local cooldownUntil = tonumber(getgenv().ufoPetCooldownUntil) or 0
                    if os.clock() < cooldownUntil then
                        task.wait(math.min(0.1, cooldownUntil - os.clock()))
                        continue
                    end

                    pcall(function()
                        local remotes = replicatedStorage:FindFirstChild("Remotes")
                        local petChicken = remotes and remotes:FindFirstChild("PetChicken")

                        if petChicken and petChicken:IsA("RemoteEvent") then
                            petChicken:FireServer()
                        end
                    end)

                    task.wait(math.clamp(tonumber(getgenv().autoPetDelay) or 0.5, 0.5, 15))
                end

                getgenv().autoPetLoopActive = false
            end)
        end
    end)

    local AutoPetDelayInput = Tabs.Farm:AddInput("AutoPetDelayInput", {
        Title = "ดีเลย์ลูบไก่",
        Default = tostring(getgenv().autoPetDelay),
        Placeholder = "0.5 - 15",
        Numeric = true,
        Finished = true,
        Callback = function(Value)
            local number = tonumber(Value)
            if number then
                getgenv().autoPetDelay = math.clamp(number, 0.5, 15)
            end
        end
    })

    local AutoScrap = Tabs.Farm:AddToggle("AutoScrap", {
        Title = "เก็บเศษเหล็กอัตโนมัติ",
        Default = false
    })

    AutoScrap:OnChanged(function(Value)
        getgenv().autoScrapEnabled = Value

        if Value then
            startScrapNoclip()
        else
            stopScrapNoclip()
        end

        if Value and not getgenv().autoScrapLoopActive then
            getgenv().autoScrapLoopActive = true

            task.spawn(function()
                while getgenv().autoScrapEnabled do
                    pcall(function()
                        if getScrapStackCount() > 6 then
                            depositAtRecycler()
                        else
                            collectNearbyScrap()
                        end
                    end)

                    task.wait(1)
                end

                getgenv().autoScrapLoopActive = false
            end)
        end
    end)

    local AutoIncubatorClaim = Tabs.Farm:AddToggle("AutoIncubatorClaim", {
        Title = "เก็บไข่ในตู้อัตโนมัติ",
        Default = false
    })

    AutoIncubatorClaim:OnChanged(function(Value)
        getgenv().autoIncubatorClaimEnabled = Value

        if Value and not getgenv().autoIncubatorClaimLoopActive then
            getgenv().autoIncubatorClaimLoopActive = true

            task.spawn(function()
                while getgenv().autoIncubatorClaimEnabled do
                    pcall(function()
                        local incubatorRemote = replicatedStorage
                            :WaitForChild("Remotes", 10)
                            :WaitForChild("IncubatorClaim", 10)

                        if incubatorRemote and incubatorRemote:IsA("RemoteFunction") then
                            incubatorRemote:InvokeServer()
                        end
                    end)

                    for _ = 1, 300 do
                        if not getgenv().autoIncubatorClaimEnabled then
                            break
                        end
                        task.wait(1)
                    end
                end

                getgenv().autoIncubatorClaimLoopActive = false
            end)
        end
    end)

    -- ARENA TAB
    local AutoArena = Tabs.Arena:AddToggle("AutoArena", {
        Title = "ลงอารีน่าอัตโนมัติ",
        Default = false
    })

    AutoArena:OnChanged(function(Value)
        getgenv().autoArenaEnabled = Value

        if Value and not getgenv().autoArenaLoopActive then
            getgenv().autoArenaLoopActive = true

            task.spawn(function()
                while getgenv().autoArenaEnabled do
                    pcall(function()
                        local remotes = replicatedStorage:FindFirstChild("Remotes")
                        local arenaFight = remotes and remotes:FindFirstChild("ArenaFight")

                        -- Only attempt Fight. If Fight is not currently available,
                        -- InvokeServer errors and the loop simply waits for the next check.
                        if arenaFight and arenaFight:IsA("RemoteFunction") then
                            arenaFight:InvokeServer()
                        end
                    end)

                    task.wait(0.5)
                end

                getgenv().autoArenaLoopActive = false
            end)
        end
    end)

    -- When the configured Rebirth Limit is reached, fully switch OFF both
    -- Tower and Auto Rebirth. They can only run again after the user enables
    -- the toggle again, and each re-enable checks the limit first.
    function disableTowerRebirthAtLimit()
        getgenv().autoTowerEnabled = false
        getgenv().autoRebirthEnabled = false
        getgenv().autoTowerWaitingAfterRebirth = false

        pcall(function()
            if AutoTower then
                AutoTower:SetValue(false)
            end
        end)

        pcall(function()
            if AutoRebirth then
                AutoRebirth:SetValue(false)
            end
        end)

        -- Limit is one-use: reset it to 0 immediately after the limit is reached.
        -- This lets the next session start with an unlimited/default limit.
        getgenv().rebirthLimit = 0
        pcall(function()
            if RebirthLimitInput then
                RebirthLimitInput:SetValue("0")
            end
        end)
    end


    -- Grouped toggles: row click = expand/collapse, switch click = ON/OFF.
    addCollapseArrow(AutoTower, {TowerDelayInput, LastTower}, "ลงหอคอยอัตโนมัติ")
    addCollapseArrow(AutoRebirth, {RebirthLimitInput}, "รีเบิร์ธอัตโนมัติ")
    addCollapseArrow(AutoPet, {AutoPetDelayInput}, "ลูบไก่อัตโนมัติ")
    addCollapseArrow(AutoUFO, {ufoChickenDropdown, ufoChickenRefreshButton}, "ลง UFO อัตโนมัติ")

    -- Every other Toggle in the script uses the same separate switch hitbox.
    -- Clicking its label/row no longer changes ON/OFF.
    setupToggleInteraction(LastTower)
    setupToggleInteraction(AutoBuyFeeder)
    setupToggleInteraction(AutoUpgradeFeeder)
    setupToggleInteraction(AutoUpgradeCoop)
    setupToggleInteraction(AutoUpgradeRecycler)
    setupToggleInteraction(AutoCollectEgg)
    setupToggleInteraction(AutoHotEgg)
    setupToggleInteraction(AutoScrap)
    setupToggleInteraction(AutoIncubatorClaim)
    setupToggleInteraction(AutoArena)
    setupToggleInteraction(SellRarityCommon)
    setupToggleInteraction(SellRarityUncommon)
    setupToggleInteraction(SellRarityRare)
    setupToggleInteraction(SellRarityEpic)
    setupToggleInteraction(SellRarityLegendary)
    setupToggleInteraction(SellRarityMythic)
    setupToggleInteraction(KeepRarityCommon)
    setupToggleInteraction(KeepRarityUncommon)
    setupToggleInteraction(KeepRarityRare)
    setupToggleInteraction(KeepRarityEpic)
    setupToggleInteraction(KeepRarityLegendary)
    setupToggleInteraction(KeepRarityMythic)
    setupToggleInteraction(KeepMutationInverted)
    setupToggleInteraction(KeepMutationJurassic)

    local AntiAFK = Tabs.Settings:AddToggle("AntiAFK", {
        Title = "Anti AFK",
        Default = false
    })

    AntiAFK:OnChanged(function(Value)
        setAntiAFKEnabled(Value)
    end)

    setupToggleInteraction(AntiAFK)

    local UnloadScript = Tabs.Settings:AddButton({
        Title = "กดเพื่อปิดสคริปต์",
        Callback = function()
            unloadScript()
        end
    })

    Window:SelectTab(1)
