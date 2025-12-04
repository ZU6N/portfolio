local UIS = game:GetService("UserInputService") --Services
local RunService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local DebrisService = game:GetService("Debris")
local plr = Players.LocalPlayer --Local stuff
local mouse = plr:GetMouse()
local cam = workspace.CurrentCamera
local interactRange = 15 --Basic Variables

local grabRange = 6
local hovered = nil
local grabbed = nil
local power = 60
local remote = game.ReplicatedStorage:WaitForChild("GrabRemote") --Remote event
local updatePowerText = plr.PlayerGui:WaitForChild("UpdatePower").Frame.UpdatePower --Text label for when you update power
local currentOrder = 0 --Helps clean up the UIListLayout used for the updatepower text
local sounds = require(game.ReplicatedStorage.Sound)
RunService.RenderStepped:Connect(function()
	local char = plr.Character --Checks for character and head and will continue if so
	if not char then return end
	local head = char:FindFirstChild("Head")
	if not head then return end
	local rayParams = RaycastParams.new() --Raycast to find object to grab
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {char}
	local result = workspace:Raycast(
		head.Position,
		cam.CFrame.LookVector * interactRange,
		rayParams
	)
	if result and result.Instance and result.Instance:HasTag("Moveable") and not grabbed then --Check if object is not grabbed and highlights if its not already
		if hovered ~= result.Instance then
			if hovered and hovered:FindFirstChild("Highlight") then
				hovered.Highlight:Destroy()
			end
			hovered = result.Instance
			local hl = Instance.new("Highlight")
			hl.FillTransparency = 0.85
			hl.FillColor = Color3.new(1,1,1)
			hl.Parent = hovered
		end
	else
		if hovered and hovered:FindFirstChild("Highlight") then --Looking away from object destroys highlight
			hovered.Highlight:Destroy()
		end
		hovered = nil
	end
end)
local function updatePowerUI()
	task.spawn(function()
		sounds.makeAudio(87437544236708,0.67,2,game.Workspace)
		currentOrder += 1
		local newPowerText = updatePowerText:Clone() --Clones text because there is UIListLayout
		local powerTInfo = TweenInfo.new(0.4) --Some tween stuff
		local powerTweenOut = tweenService:Create(newPowerText,powerTInfo,{TextTransparency = 1, TextStrokeTransparency = 1})
		local powerTweenIn = tweenService:Create(newPowerText,powerTInfo,{TextTransparency = 0, TextStrokeTransparency = 0})
		newPowerText.TextColor3 = Color3.fromRGB(142, 255, 155) --Colors which one is most recent, uncoloring the ones that are in the past
		for _, i in ipairs(updatePowerText.Parent:GetChildren()) do
			if i ~= newPowerText and i:IsA("TextLabel") then
				i.TextColor3 = Color3.new(1,1,1)
			end
		end
		newPowerText.Parent = updatePowerText.Parent --The rest is just the visual effects of the ui
		newPowerText.LayoutOrder = currentOrder
		newPowerText.Text = "Updated Power: "..power
		newPowerText.Visible = true
		powerTweenIn:Play()
		powerTweenIn.Completed:Wait()
		powerTweenOut:Play()
		powerTweenOut.Completed:Wait()
		newPowerText:Destroy()
	end)
end
UIS.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then --Mouse Click
		if hovered and not grabbed then --If the object looked at is hovered and nothing is grabbed currently, it will grab the item
			grabbed = hovered
			remote:FireServer("Grab", hovered, grabRange) --Fire grab event
		else --If object is already grabbed then it will be released
			grabbed = nil
			remote:FireServer("Release") --Fire release event
		end
	end
	if input.KeyCode == Enum.KeyCode.Q then --Q Pressed
		if grabbed and grabbed.Anchored == false then
			sounds.makeAudio(85438893235934,0.5,3,plr.Character.Head)
			grabbed = nil 
			remote:FireServer("Throw",power) --Throw object
		end
		
	end
	if input.KeyCode == Enum.KeyCode.Z then --Q Pressed
		remote:FireServer("Anchor",hovered) --Throw object
	end
	if input.KeyCode == Enum.KeyCode.E then --E Pressed
		power += 2.5
		updatePowerUI() --Update the ui
	end
	if input.KeyCode == Enum.KeyCode.R then --R Pressed
		power -= 2.5
		updatePowerUI() -- Update the UI
	end
	if input.KeyCode == Enum.KeyCode.LeftAlt then
		if plr.PlayerGui.ItemSpawn.Frame.Visible == true then
			plr.PlayerGui.ItemSpawn.Frame.Visible = false
			plr.PlayerGui.ItemSpawn.UnlockMouse.Visible = false
		else
			plr.PlayerGui.ItemSpawn.Frame.Visible = true
			plr.PlayerGui.ItemSpawn.UnlockMouse.Visible = true
		end
		
	end
end)
mouse.WheelForward:Connect(function() --Scroll up
	grabRange = math.clamp(grabRange + 1, 3, interactRange)
	remote:FireServer("SetDistance", grabRange) --Increases hold distance
end)
mouse.WheelBackward:Connect(function() --Scroll down
	grabRange = math.clamp(grabRange - 1, 3, interactRange)
	remote:FireServer("SetDistance", grabRange) --Lowers hold distance
end)
RunService.RenderStepped:Connect(function() --Update camera
	remote:FireServer("UpdateCamera", cam.CFrame)
end)