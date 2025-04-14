if not game:IsLoaded() then
	game.Loaded:Wait()
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

local renderedFolder = workspace:WaitForChild("Rendered")

local pickupsFolder
local function findPickupsFolder()
	for _, folder in pairs(renderedFolder:GetChildren()) do
		if folder.Name == "Chunker" and #folder:GetChildren() > 10 then
			pickupsFolder = folder
		end
	end
end

findPickupsFolder()

local function findClosePickups()
	local nearbyPickups = {}
	
	for _,pickup in pairs(pickupsFolder:GetChildren()) do
		local part = pickup:FindFirstChildWhichIsA("MeshPart") or pickup:FindFirstChildWhichIsA("Part")
		if part and player:DistanceFromCharacter(part.Position) < 65 and part.Position.Y - HR.Position.Y < 10 then
			table.insert(nearbyPickups, part)
		end
	end
	
	return nearbyPickups
end

local clip = true
local function noClip()
	clip = false
	while clip == false and task.wait() do
        for _, child in pairs(character:GetDescendants()) do
            if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= floatName then
                child.CanCollide = false
            end
    	end
    end
end

local function yesClip()
	clip = true
end


local function makeFloat(value)
	if value == false then
		BV.MaxForce = Vector3.new(0,0,0)
		return
	end
	
	BV.MaxForce = Vector3.new(0,math.huge,0)
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

local autoPickingUp = false
local function autoPickupPickupables()
	local pickups = findClosePickups()
	
	for _,pickup in pairs(pickups) do
		if pickup.Parent ~= nil then
			MoveToWithTimeOut(pickup.Position, 2)
		end
	end
end

local blowingBubble = false
local function blowBubble()
	game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer("BlowBubble")
end

local sellingBubble = false
local function sellBubble()
	game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer("SellBubble")
end

local function goStraightUp()
	
	HR.CFrame = HR.CFrame + Vector3.new(0,3000,0)
end

local autoSpin = false
local function claimSpin()
	game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer("ClaimFreeWheelSpin")
end

local function spinWheel()
	game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Function"):InvokeServer("WheelSpin")
end

local spinTimeLabel = player.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("WheelSpin"):WaitForChild("Frame"):WaitForChild("Main"):WaitForChild("Buttons"):WaitForChild("Free"):WaitForChild("Button"):WaitForChild("Label")

local function spinAvailable() 
	return spinTimeLabel.Text == "FREE SPIN"
end

local autoChest = false
local function claimChest(chestName)
	local args = {
    [1] = "ClaimChest",
    [2] = chestName
	}

	game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))

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
		clip = true
		makeFloat(false)
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
			CmdHandler.Visible = false
		else
			Background.BackgroundTransparency = 0
			CmdHandler.Visible = true
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

	CmdName.MouseButton1Down:Connect(function()Dragg = true while Dragg do game.TweenService:Create(Background, TweenInfo.new(.06), {Position = UDim2.new(0,mouse.X-40,0,mouse.Y-5)}):Play()wait()end end)
	CmdName.MouseButton1Up:Connect(function()Dragg = false end)

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
		
		if blowingBubble == false then
			buttn1.BackgroundColor3 = Color3.fromRGB(50,100,100)
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
    buttn2.MouseButton1Click:Connect(function()
		
		sellingBubble = not sellingBubble
		
		if sellingBubble == false then
			buttn2.BackgroundColor3 = Color3.fromRGB(50,100,100)
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
    buttn3.BackgroundColor3 = Color3.fromRGB(50,50,120)
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
			buttn4.BackgroundColor3 = Color3.fromRGB(50,100,100)
			task.spawn(noClip)
			makeFloat(true)
			local savedYPosition = HR.CFrame.Position.Y
			while autoPickingUp do
				autoPickupPickupables()
				task.wait()
				
				if HR.CFrame.Position.Y ~= savedYPosition then
					HR.CFrame = HR.CFrame + Vector3.new(0, savedYPosition - HR.CFrame.Position.Y, 0)
				end
			end
		
		else
			yesClip()
			makeFloat(false)
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
    buttn5.Text = "Auto Claim and spin"
    buttn5.TextColor3 = Color3.new(1,1,1)
    buttn5.TextScaled = true
    buttn5.BackgroundTransparency = 0.3
    buttn5.MouseButton1Click:Connect(function()
		if autoSpin == false then
			autoSpin = true
			buttn5.BackgroundColor3 = Color3.fromRGB(50,150,150)
			while autoSpin do
				if spinAvailable() then
					claimSpin()
					task.wait(0.2)
					spinWheel()
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
    buttn6.Text = "Auto Claim and spin"
    buttn6.TextColor3 = Color3.new(1,1,1)
    buttn6.TextScaled = true
    buttn6.BackgroundTransparency = 0.3
    buttn6.MouseButton1Click:Connect(function()
		if autoChest == false then
			autoChest = true
			buttn6.BackgroundColor3 = Color3.fromRGB(50,150,150)
			while autoChest do
				claimChest("Giant Chest")
				task.wait(60)
			end
		
		else
			autoChest = false
			buttn6.BackgroundColor3 = Color3.fromRGB(50,50,50)
		end
	end)
	
end

createGUI()
