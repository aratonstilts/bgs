if not game:IsLoaded() then
	game.Loaded:Wait()
end

if game.CoreGui:FindFirstChild("IGUI") then
	game.CoreGui.IGUI:Destroy()
end

local mouse = game.Players.LocalPlayer:GetMouse()
repeat 
	wait(0.5) 
	mouse = game.Players.LocalPlayer:GetMouse() 
until mouse

local Players = game:GetService("Players")
local player = game:GetService("Players").LocalPlayer
local BV = Instance.new("BodyVelocity")

local function onCharacterAdded(char)
	print("character added!")
	humanoid = char:WaitForChild("Humanoid")
	character = char
	HR = char:WaitForChild("HumanoidRootPart")
	BV.MaxForce = Vector3.new(0,0,0)
	BV.Velocity = Vector3.new(0,0,0)
	BV.Parent = HR
end

local character = player.Character
if character then
	onCharacterAdded(character)
end

player.CharacterAdded:Connect(onCharacterAdded)

local TS = game:GetService("TweenService")

local remoteFolder = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote")
local functionFunction = remoteFolder:WaitForChild("Function")
local eventEvent = remoteFolder:WaitForChild("Event")

local renderedFolder = workspace:WaitForChild("Rendered")

local pickupsFolder
local function findPickupsFolder()

	if pickupsFolder then return pickupsFolder end

	for _, folder in pairs(renderedFolder:GetChildren()) do
	
		if folder.Name == "Chunker" then
		
			local folderContents = folder:GetChildren()
			
			if #folderContents == 0 then continue end
			
			local meshpart = folderContents[1]:FindFirstChildWhichIsA("MeshPart")
			
			if meshpart and meshpart.Name:find("Meshes") then
				pickupsFolder = folder
			end
			
		end
	end
end



local function findClosePickups()
	pickupsFolder = findPickupsFolder()
	local nearbyPickups = {}
	
	for _,pickup in pairs(pickupsFolder:GetChildren()) do
		local part = pickup:FindFirstChildWhichIsA("MeshPart") or pickup:FindFirstChildWhichIsA("Part")
		
		if part and player:DistanceFromCharacter(part.Position) < 65 and part.Position.Y - HR.Position.Y < 10 then
			table.insert(nearbyPickups, part)
		end
	end
	
	return nearbyPickups
end

local playerGUI = game:GetService("Players").LocalPlayer.PlayerGui
local screenGUI = playerGUI:WaitForChild("ScreenGui")
local notifications = screenGUI:WaitForChild("Notifications")

local petMatchReady = false
local cartEscapeReady = false

local notificationChecker = notifications.ChildAdded:Connect(function(screenAdded)
	local content = screenAdded:WaitForChild("Content")
	local label = content:WaitForChild("Label")
	
	if string.lower(label.Text):find("pet match") then
		petMatchReady = true
	end
	
	if string.lower(label.Text):find("cart escape") then
		cartEscapeReady = true
	end
	
end)

local function makeFloat(value)
	if value == false then
		BV.MaxForce = Vector3.new(0,0,0)
		return
	end
	
	BV.MaxForce = Vector3.new(0,math.huge,0)
end

local worldFolder = workspace:WaitForChild("Worlds"):WaitForChild("The Overworld")
local islandsFolder = worldFolder:WaitForChild("Islands")
local zenIsland = islandsFolder:WaitForChild("Zen"):WaitForChild("Island")
local board = zenIsland:WaitForChild("Board")
local doubleGemsBoard = zenIsland:WaitForChild("Double Gems")
local changedItems = {}

local function makeIslandNoClip()
	for i,v in pairs(zenIsland:GetDescendants()) do
		if v:IsA("MeshPart") or v:IsA("Part") then
			if v.Name:find("Circle") then
				continue
			end
			if v.CanCollide == true then
				v.CanCollide = false
				table.insert(changedItems, v)
			end
		end
	end
end

local function makeIslandNormal()
	for i,v in pairs(changedItems) do
		if v.CanCollide == false then
			v.CanCollide = true
		end
	end
	
	changedItems = {}
end


local MoveId = 0
local function MoveToWithTimeOut(vector3,timeout)
	MoveId = (MoveId + 1)%1000
	local fnMoveId = MoveId

	humanoid:MoveTo(vector3)

	coroutine.wrap(function()
		wait(timeout)
		if fnMoveId == MoveId then 
			humanoid:Move(Vector3.new())
		end
	end)()
end

local function checkHumanoidState()
	return humanoid:GetState()
end

local function teleport()
	local args = {
		[1] = "Teleport",
		[2] = "Workspace.Worlds.The Overworld.Islands.Zen.Island.Portal.Spawn"
	}

	eventEvent:FireServer(unpack(args))

end


local function fixProblem()
	task.wait(0.5)
	teleport()
	task.wait(0.5)
end

local timeout = 5
local recentFixes = 0

local function notRecentAnymore()
	task.wait(20)
	recentFixes = recentFixes - 1
end

local function fixHumanoidState()
	if checkHumanoidState() == Enum.HumanoidStateType.Freefall then
		recentFixes = recentFixes + 1
		makeFloat(false)
		task.wait(0.5)
		makeFloat(true)
	end
	
	if recentFixes > 4 then
		fixProblem()
	end
	
	task.spawn(notRecentAnymore)
end

local autoPickingUp = false
local function autoPickupPickupables()
	local pickups = findClosePickups()
	
	for _,pickup in pairs(pickups) do
		if pickup.Parent ~= nil then
			MoveToWithTimeOut(pickup.Position, 2)
		end
	end
end

local autoPlaytime = false
local function claimPlaytimeRewards()
	for i = 1,9 do
		local args = {
			[1] = "ClaimPlaytime",
			[2] = i
		}
		functionFunction:InvokeServer(unpack(args))
	end
end

local blowingBubble = false
local function blowBubble()
	eventEvent:FireServer("BlowBubble")
end

local sellingBubble = false
local function sellBubble()
	eventEvent:FireServer("SellBubble")
end

local function goStraightUp()
	
	HR.CFrame = HR.CFrame + Vector3.new(0,3000,0)
end

local autoSpin = false
local function claimSpin()
	eventEvent:FireServer("ClaimFreeWheelSpin")
end

local spinTimeLabel = screenGUI:WaitForChild("WheelSpin"):WaitForChild("Frame"):WaitForChild("Main"):WaitForChild("Buttons"):WaitForChild("Free"):WaitForChild("Button"):WaitForChild("Label")

local function spinAvailable() 
	return spinTimeLabel.Text == "FREE SPIN"
end

local autoChest = false
local chestsFolder = renderedFolder:WaitForChild("Chests")

local function getCurrentChests()
	local currentChests = chestsFolder:GetChildren()
	
	local chestNames = {}
	
	for _,chest in pairs(currentChests) do
		table.insert(chestNames, chest.Name)
	end
	
	return chestNames
		
end

local function claimChest(chestName)
	local args = {
		[1] = "ClaimChest",
		[2] = chestName,
		[3] = true
	}

	eventEvent:FireServer(unpack(args))
end

local function teleport(area, subArea)

	if subArea == "Spawn" then
		eventEvent:FireServer("Teleport", "Workspace.Worlds."..area..".FastTravel."..subArea)
		return
	end
	
	eventEvent:FireServer("Teleport", "Workspace.Worlds."..area..".Islands."..subArea..".Island.Portal.Spawn")
	
end

teleportBackgroundActive = false

local currentAreas = {
	["The Overworld"] = {"Spawn", "Floating Island", "Outer Space", "Twilight", "Zen", "The Void"},
	["Minigame Paradise"] = {"Spawn", "Robot Factory", "Minecart Forest", "Dice Island"}
}

local function addTeleportButton(background, area, subArea)
	local buttn = Instance.new("TextButton")
    buttn.Size = UDim2.new(1,0,0,20)
    buttn.BackgroundColor3 = Color3.fromRGB(50,50,200)
    buttn.BorderColor3 = Color3.new(1,1,1)
    buttn.ZIndex = 2
    buttn.Parent = background
    buttn.Text = area.." - "..subArea
    buttn.TextColor3 = Color3.new(1,1,1)
    buttn.TextScaled = true
    buttn.BackgroundTransparency = 0.3
    buttn.MouseButton1Click:Connect(function()
		teleport(area, subArea)
	end)
end

local function createTeleportBackground(mainBackground)

	local background = Instance.new("Frame")
	
	background.Name = "teleportBackground"
	background.Parent = mainBackground
	background.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	background.BorderSizePixel = 0
	background.BorderColor3 = Color3.new(1,0,1)
	background.Position = UDim2.new(1, 0, 0, 0)
	background.Size = UDim2.new(2, 0, 1, 0)
	background.Active = true
	
	local scrFrame = Instance.new("ScrollingFrame")
	scrFrame.Name = "scrFrame"
	scrFrame.Parent = background
	scrFrame.Active = true
	scrFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
	scrFrame.BackgroundTransparency = 1.000
	scrFrame.BorderSizePixel = 0
	scrFrame.AutomaticCanvasSize = "Y"
	scrFrame.Position = UDim2.new(0, 5, 0, 19)
	scrFrame.Size = UDim2.new(1, -5, 1, -5)
	scrFrame.ScrollBarThickness = 4
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0,2)
	listLayout.Parent = scrFrame
	
	for area,subAreas in pairs(currentAreas) do
		for i = 1, #subAreas do
			addTeleportButton(scrFrame, area, subAreas[i])
		end
	end
end

local codes = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Codes"))

local function redeemCodes()

	for code,tab in pairs(codes) do

		functionFunction:InvokeServer("RedeemCode", code)

	end
	
end


local function finishMinigame()
	eventEvent:FireServer("FinishMinigame")
end

local function startMinigame(minigame, difficulty)
	eventEvent:FireServer("StartMinigame", minigame, difficulty)
end


local rifts = renderedFolder:WaitForChild("Rifts")

local function goToRift(rift)

	local riftCFrame = rift:GetPivot()
	
	makeFloat(true)

	HR.CFrame = HR.CFrame + Vector3.new(0, riftCFrame.Position.Y - HR.CFrame.Position.Y + 10 ,0)

	local goal = {}
	goal.CFrame = riftCFrame + Vector3.new(0,10,0)
	
	local Distance = (HR.Position - riftCFrame.Position).Magnitude
	local Speed = 20
	local Time = Distance/Speed

	local tween = TS:Create(HR, TweenInfo.new(Time, Enum.EasingStyle.Linear), goal)
	tween:Play()
	tween.Completed:Wait()

	makeFloat(false)

end

local openingRiftChest = false

local function openRiftChest(chestName)

	local args = {
		[1] = "UnlockRiftChest",
		[2] = chestName,
		[3] = false
	}

	game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))

end

riftBackgroundActive = false

local function addRiftButton(background, rift)
	local buttn = Instance.new("TextButton")
    buttn.Size = UDim2.new(0,100,0,20)
    buttn.BackgroundColor3 = Color3.fromRGB(50,50,200)
    buttn.BorderColor3 = Color3.new(1,1,1)
    buttn.ZIndex = 2
    buttn.Parent = background
    buttn.Text = rift.Name
    buttn.TextColor3 = Color3.new(1,1,1)
    buttn.TextScaled = true
    buttn.BackgroundTransparency = 0.3
    buttn.MouseButton1Click:Connect(function()
		goToRift(rift)
	end)
end

local function createRiftBackground(mainBackground)

	local background = Instance.new("Frame")
	
	background.Name = "riftsBackground"
	background.Parent = mainBackground
	background.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	background.BorderSizePixel = 0
	background.BorderColor3 = Color3.new(1,0,1)
	background.Position = UDim2.new(1, 0, 0, 0)
	background.Size = UDim2.new(1, 0, 1, 0)
	background.Active = true
	
	local scrFrame = Instance.new("ScrollingFrame")
	scrFrame.Name = "scrFrame"
	scrFrame.Parent = background
	scrFrame.Active = true
	scrFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
	scrFrame.BackgroundTransparency = 1.000
	scrFrame.BorderSizePixel = 0
	scrFrame.AutomaticCanvasSize = "Y"
	scrFrame.Position = UDim2.new(0, 5, 0, 19)
	scrFrame.Size = UDim2.new(0, 113, 0, 250)
	scrFrame.ScrollBarThickness = 4
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0,2)
	listLayout.Parent = scrFrame
	
	for _,rift in pairs(rifts:GetChildren()) do
		addRiftButton(scrFrame, rift)
	end
end

local function createGUI()
	local CmdGui = Instance.new("ScreenGui")
	local Background = Instance.new("Frame")
	local CmdHandler = Instance.new("ScrollingFrame")
	local Close = Instance.new("TextButton")
	local Minimum = Instance.new("TextButton")
	local CmdName = Instance.new("TextButton")
	
	CmdGui.Name = "IGUI"
	CmdGui.Parent = game:GetService("CoreGui")
	
	Background.Name = "Background"
	Background.Parent = CmdGui
	Background.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	Background.BorderSizePixel = 0
	Background.BorderColor3 = Color3.new(1,0,1)
	Background.Position = UDim2.new(0.06, 0, 0.20, 0)
	Background.Size = UDim2.new(0, 120, 0, 275)
	Background.Active = true
	
	CmdHandler.Name = "CmdHandler"
	CmdHandler.Parent = Background
	CmdHandler.Active = true
	CmdHandler.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
	CmdHandler.BackgroundTransparency = 1.000
	CmdHandler.BorderSizePixel = 0
	CmdHandler.AutomaticCanvasSize = "Y"
	CmdHandler.Position = UDim2.new(0, 5, 0, 19)
	CmdHandler.Size = UDim2.new(0, 113, 0, 250)
	CmdHandler.ScrollBarThickness = 4
	
	Close.Name = "Close"
	Close.Parent = Background
	Close.BackgroundColor3 = Color3.fromRGB(155, 0, 0)
	Close.BorderSizePixel = 0
	Close.Position = UDim2.new(0.87, 0, 0.0001, 0)
	Close.Size = UDim2.new(0, 15, 0, 15)
	Close.Font = Enum.Font.SourceSans
	Close.Text = "X"
	Close.TextColor3 = Color3.fromRGB(255, 255, 255)
	Close.TextSize = 14.000
	Close.MouseButton1Click:Connect(function() 
		blowingBubble = false
		sellingBubble = false
		autoPickingUp = false
		autoChest = false
		autoPlaytime = false
		makeFloat(false)
		riftBackgroundActive = false
		teleportBackgroundActive = false
		openingRiftChest = false
		notificationChecker:Disconnect()
		CmdGui:Destroy()
	end)
	
	Minimum.Name = "Minimum"
	Minimum.Parent = Background
	Minimum.BackgroundColor3 = Color3.fromRGB(0, 155, 155)
	Minimum.BorderSizePixel = 0
	Minimum.Position = UDim2.new(0.74, 0, 0.0001, 0)
	Minimum.Size = UDim2.new(0, 15, 0, 14)
	Minimum.Font = Enum.Font.SourceSans
	Minimum.Text = "-"
	Minimum.TextColor3 = Color3.fromRGB(255, 255, 255)
	Minimum.TextSize = 14.000
	Minimum.MouseButton1Click:Connect(function()
		if Background.BackgroundTransparency == 0 then
			Background.BackgroundTransparency = 1
			Background.Active = false
			CmdHandler.Visible = false
		else
			Background.BackgroundTransparency = 0
			CmdHandler.Visible = true
			Background.Active = true
		end
	end)

	CmdName.Name = "CmdName"
	CmdName.AutoButtonColor = false
	CmdName.Parent = Background
	CmdName.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	CmdName.BorderSizePixel = 0
	CmdName.Size = UDim2.new(0, 87, 0, 15)
	CmdName.Font = Enum.Font.GothamBlack
	CmdName.Text = "BGS Infinity"
	CmdName.TextColor3 = Color3.fromRGB(255, 255, 255)
	CmdName.TextScaled = true
	CmdName.TextSize = 14.000
	CmdName.TextWrapped = true
	Dragg = false

	CmdName.MouseButton1Down:Connect(function()
		Dragg = true 
		while Dragg do 
			TS:Create(Background, TweenInfo.new(.06), {Position = UDim2.new(0,mouse.X-40,0,mouse.Y-5)}):Play()
			wait()
		end 
	end)
	
	CmdName.MouseButton1Up:Connect(function()
		Dragg = false 
	end)

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0,2)
	listLayout.Parent = CmdHandler
	
	buttn1 = Instance.new("TextButton")
    buttn1.Size = UDim2.new(0,100,0,20)
    buttn1.BackgroundColor3 = Color3.fromRGB(50,50,50)
    buttn1.BorderColor3 = Color3.new(1,1,1)
    buttn1.ZIndex = 2
    buttn1.Parent = CmdHandler
    buttn1.Text = "Auto Blow Bubble"
    buttn1.TextColor3 = Color3.new(1,1,1)
    buttn1.TextScaled = true
    buttn1.BackgroundTransparency = 0.3
    buttn1.MouseButton1Click:Connect(function()
		
		blowingBubble = not blowingBubble
		
		if blowingBubble == true then
			buttn1.BackgroundColor3 = Color3.fromRGB(50,200,200)
		else
			buttn1.BackgroundColor3 = Color3.fromRGB(50,50,50)
		end
		
        while blowingBubble == true do
			task.wait(0.1)
			blowBubble()
		end
    end)
	
	buttn2 = Instance.new("TextButton")
    buttn2.Size = UDim2.new(0,100,0,20)
    buttn2.BackgroundColor3 = Color3.fromRGB(50,50,50)
    buttn2.BorderColor3 = Color3.new(1,1,1)
    buttn2.ZIndex = 2
    buttn2.Parent = CmdHandler
    buttn2.Text = "Auto Sell Bubble"
    buttn2.TextColor3 = Color3.new(1,1,1)
    buttn2.TextScaled = true
    buttn2.BackgroundTransparency = 0.3
	
	buttn2.Visible = false
	
    buttn2.MouseButton1Click:Connect(function()
		
		sellingBubble = not sellingBubble
		
		if sellingBubble == true then
			buttn2.BackgroundColor3 = Color3.fromRGB(50,200,200)
		else
			buttn2.BackgroundColor3 = Color3.fromRGB(50,50,50)
		end
		
        while sellingBubble == true do
			sellBubble()
			task.wait(20)
		end
    end)
	
	buttn3 = Instance.new("TextButton")
    buttn3.Size = UDim2.new(0,100,0,20)
    buttn3.BackgroundColor3 = Color3.fromRGB(50,50,200)
    buttn3.BorderColor3 = Color3.new(1,1,1)
    buttn3.ZIndex = 2
    buttn3.Parent = CmdHandler
    buttn3.Text = "Go up"
    buttn3.TextColor3 = Color3.new(1,1,1)
    buttn3.TextScaled = true
    buttn3.BackgroundTransparency = 0.3
    buttn3.MouseButton1Click:Connect(function()
		goStraightUp()
	end)
	
	buttn4 = Instance.new("TextButton")
    buttn4.Size = UDim2.new(0,100,0,20)
    buttn4.BackgroundColor3 = Color3.fromRGB(50,50,50)
    buttn4.BorderColor3 = Color3.new(1,1,1)
    buttn4.ZIndex = 2
    buttn4.Parent = CmdHandler
    buttn4.Text = "Auto Pickup Nearby"
    buttn4.TextColor3 = Color3.new(1,1,1)
    buttn4.TextScaled = true
    buttn4.BackgroundTransparency = 0.3
    buttn4.MouseButton1Click:Connect(function()
		if autoPickingUp == false then
			autoPickingUp = true
			buttn4.BackgroundColor3 = Color3.fromRGB(50,200,200)
			makeIslandNoClip()
			makeFloat(true)
			local savedYPosition = HR.CFrame.Position.Y
			while autoPickingUp do
				autoPickupPickupables()
				task.wait()
				
				if HR.CFrame.Position.Y ~= savedYPosition then
					HR.CFrame = HR.CFrame + Vector3.new(0, savedYPosition - HR.CFrame.Position.Y, 0)
				end
				
				fixHumanoidState()
			end
		
		else
			makeFloat(false)
			makeIslandNormal()
			autoPickingUp = false
			buttn4.BackgroundColor3 = Color3.fromRGB(50,50,50)
		end
	end)
	
	buttn5 = Instance.new("TextButton")
    buttn5.Size = UDim2.new(0,100,0,20)
    buttn5.BackgroundColor3 = Color3.fromRGB(50,50,50)
    buttn5.BorderColor3 = Color3.new(1,1,1)
    buttn5.ZIndex = 2
    buttn5.Parent = CmdHandler
    buttn5.Text = "Auto Claim spin ticket"
    buttn5.TextColor3 = Color3.new(1,1,1)
    buttn5.TextScaled = true
    buttn5.BackgroundTransparency = 0.3
    buttn5.MouseButton1Click:Connect(function()
		if autoSpin == false then
			autoSpin = true
			buttn5.BackgroundColor3 = Color3.fromRGB(50,200,200)
			while autoSpin do
				if spinAvailable() then
					claimSpin()
				end
				task.wait(1)
			end
		
		else
			autoSpin = false
			buttn5.BackgroundColor3 = Color3.fromRGB(50,50,50)
		end
	end)
	
	buttn6 = Instance.new("TextButton")
    buttn6.Size = UDim2.new(0,100,0,20)
    buttn6.BackgroundColor3 = Color3.fromRGB(50,50,50)
    buttn6.BorderColor3 = Color3.new(1,1,1)
    buttn6.ZIndex = 2
    buttn6.Parent = CmdHandler
    buttn6.Text = "Auto Claim Chests"
    buttn6.TextColor3 = Color3.new(1,1,1)
    buttn6.TextScaled = true
    buttn6.BackgroundTransparency = 0.3
    buttn6.MouseButton1Click:Connect(function()
		if autoChest == false then
			autoChest = true
			buttn6.BackgroundColor3 = Color3.fromRGB(50,200,200)
			
			local chestNames = getCurrentChests()
			
			while autoChest do
				for _, chestName in pairs(chestNames) do
					claimChest(chestName)
					task.wait(1)
				end
				task.wait(60)
			end
		
		else
			autoChest = false
			buttn6.BackgroundColor3 = Color3.fromRGB(50,50,50)
		end
	end)
	
	buttn7 = Instance.new("TextButton")
    buttn7.Size = UDim2.new(0,100,0,20)
    buttn7.BackgroundColor3 = Color3.fromRGB(50,50,50)
    buttn7.BorderColor3 = Color3.new(1,1,1)
    buttn7.ZIndex = 2
    buttn7.Parent = CmdHandler
    buttn7.Text = "Auto Claim Playtime"
    buttn7.TextColor3 = Color3.new(1,1,1)
    buttn7.TextScaled = true
    buttn7.BackgroundTransparency = 0.3
    buttn7.MouseButton1Click:Connect(function()
		if autoPlaytime == false then
			autoPlaytime = true
			buttn7.BackgroundColor3 = Color3.fromRGB(50,200,200)
			while autoPlaytime do
				claimPlaytimeRewards()
				task.wait(60)
			end
		
		else
			autoPlaytime = false
			buttn7.BackgroundColor3 = Color3.fromRGB(50,50,50)
		end
	end)
	
	buttn8 = Instance.new("TextButton")
    buttn8.Size = UDim2.new(0,100,0,20)
    buttn8.BackgroundColor3 = Color3.fromRGB(50,50,50)
    buttn8.BorderColor3 = Color3.new(1,1,1)
    buttn8.ZIndex = 2
    buttn8.Parent = CmdHandler
    buttn8.Text = "Show all Rifts"
    buttn8.TextColor3 = Color3.new(1,1,1)
    buttn8.TextScaled = true
    buttn8.BackgroundTransparency = 0.3
    buttn8.MouseButton1Click:Connect(function()
		if riftBackgroundActive == false then
			riftBackgroundActive = true
			buttn8.BackgroundColor3 = Color3.fromRGB(50,200,200)
			buttn8.Text = "Hide all Rifts"
			createRiftBackground(Background)
		
		else
			riftBackgroundActive = false
			buttn8.BackgroundColor3 = Color3.fromRGB(50,50,50)
			buttn8.Text = "Show all Rifts"
			if Background:FindFirstChild("riftsBackground") then 
				Background.riftsBackground:Destroy() 
			end
		end
	end)
	
	buttn9 = Instance.new("TextButton")
    buttn9.Size = UDim2.new(0,100,0,20)
    buttn9.BackgroundColor3 = Color3.fromRGB(50,50,50)
    buttn9.BorderColor3 = Color3.new(1,1,1)
    buttn9.ZIndex = 2
    buttn9.Parent = CmdHandler
    buttn9.Text = "Teleports>"
    buttn9.TextColor3 = Color3.new(1,1,1)
    buttn9.TextScaled = true
    buttn9.BackgroundTransparency = 0.3
    buttn9.MouseButton1Click:Connect(function()
		if teleportBackgroundActive == false then
			teleportBackgroundActive = true
			buttn9.BackgroundColor3 = Color3.fromRGB(50,200,200)
			buttn9.Text = "Teleports<"
			createTeleportBackground(Background)
		
		else
			teleportBackgroundActive = false
			buttn9.BackgroundColor3 = Color3.fromRGB(50,50,50)
			buttn9.Text = "Teleports>"
			if Background:FindFirstChild("teleportBackground") then 
				Background.teleportBackground:Destroy() 
			end
		end
	end)
	
	
	
	buttn10 = Instance.new("TextButton")
    buttn10.Size = UDim2.new(0,100,0,20)
    buttn10.BackgroundColor3 = Color3.fromRGB(50,50,50)
    buttn10.BorderColor3 = Color3.new(1,1,1)
    buttn10.ZIndex = 2
    buttn10.Parent = CmdHandler
    buttn10.Text = "Auto open gold chest"
    buttn10.TextColor3 = Color3.new(1,1,1)
    buttn10.TextScaled = true
    buttn10.BackgroundTransparency = 0.3
    buttn10.MouseButton1Click:Connect(function()
		if openingRiftChest == false then
			openingRiftChest = true
			buttn10.BackgroundColor3 = Color3.fromRGB(50,200,200)
			buttn10.Text = "Auto open gold chest"
			
			while openingRiftChest == true do
				openRiftChest("golden-chest")
				task.wait()
			end
		
		else
			openingRiftChest = false
			buttn10.BackgroundColor3 = Color3.fromRGB(50,50,50)
			buttn10.Text = "Auto open gold chest"
		end
	end)
	
	buttn11 = Instance.new("TextButton")
    buttn11.Size = UDim2.new(0,100,0,20)
    buttn11.BackgroundColor3 = Color3.fromRGB(50,50,50)
    buttn11.BorderColor3 = Color3.new(1,1,1)
    buttn11.ZIndex = 2
    buttn11.Parent = CmdHandler
    buttn11.Text = "Redeem Codes"
    buttn11.TextColor3 = Color3.new(1,1,1)
    buttn11.TextScaled = true
    buttn11.BackgroundTransparency = 0.3
    buttn11.MouseButton1Click:Connect(function()
		redeemCodes()
	end)
	
	local autoMinecart = false
	local autoPetMatch = false
	local playingMinigame = false
	petMatchReady = false
	cartEscapeReady = false
	
	buttn12 = Instance.new("TextButton")
    buttn12.Size = UDim2.new(0,100,0,20)
    buttn12.BackgroundColor3 = Color3.fromRGB(50,50,50)
    buttn12.BorderColor3 = Color3.new(1,1,1)
    buttn12.ZIndex = 2
    buttn12.Parent = CmdHandler
    buttn12.Text = "Autoplay cart escape"
    buttn12.TextColor3 = Color3.new(1,1,1)
    buttn12.TextScaled = true
    buttn12.BackgroundTransparency = 0.3
    buttn12.MouseButton1Click:Connect(function()
		if autoMinecart == false then
			autoMinecart = true
			buttn12.BackgroundColor3 = Color3.fromRGB(50,200,200)
			buttn12.Text = "autoplaying cart escape"
			cartEscapeReady = true
			while autoMinecart == true do
			
				repeat task.wait() until playingMinigame == false and cartEscapeReady == true
				
				if autoMinecart == false then return end
				
				cartEscapeReady = false
				playingMinigame = true
				startMinigame("Cart Escape", "Insane")
				task.wait(23)
				finishMinigame()
				task.wait(6)
				playingMinigame = false
			end
		
		else
			autoMinecart = false
			buttn12.BackgroundColor3 = Color3.fromRGB(50,50,50)
			buttn12.Text = "Autoplay cart escape"
		end
		
	end)
	
	buttn13 = Instance.new("TextButton")
    buttn13.Size = UDim2.new(0,100,0,20)
    buttn13.BackgroundColor3 = Color3.fromRGB(50,50,50)
    buttn13.BorderColor3 = Color3.new(1,1,1)
    buttn13.ZIndex = 2
    buttn13.Parent = CmdHandler
    buttn13.Text = "Autoplay pet match"
    buttn13.TextColor3 = Color3.new(1,1,1)
    buttn13.TextScaled = true
    buttn13.BackgroundTransparency = 0.3
    buttn13.MouseButton1Click:Connect(function()
		if autoPetMatch == false then
			autoPetMatch = true
			buttn13.BackgroundColor3 = Color3.fromRGB(50,200,200)
			buttn13.Text = "autoplaying pet match"
			petMatchReady = true
			
			while autoPetMatch == true do
			
				repeat task.wait() until playingMinigame == false and petMatchReady == true
					
				if autoPetMatch == false then return end
				
				playingMinigame = true
				petMatchReady = false
				startMinigame("Pet Match", "Insane")
				task.wait(7)
				finishMinigame()
				task.wait(6)
				playingMinigame = false
			end
		
		else
			autoPetMatch = false
			buttn13.BackgroundColor3 = Color3.fromRGB(50,50,50)
			buttn13.Text = "Autoplay pet match"
		end
	end)
end

createGUI()
