local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local player = game.Players.LocalPlayer

local uiOpen = false
local activeUI = nil

local function attachUI(part)
	local offset = CFrame.new(0, 0, -5)
	local rotate = CFrame.Angles(-math.pi, 0, math.pi)

	local info = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	local tween = nil
	local lastCF = nil
	local tweening = false

	local function setStartPos()
		part.CFrame = Camera.CFrame * offset * rotate
	end

	local function followCamera()
		local target = Camera.CFrame * offset * rotate

		if lastCF then
			if (target.Position - lastCF.Position).Magnitude < 0.01 and target.Rotation == lastCF.Rotation then
				return
			end
		end

		if not tweening then
			if tween then
				tween:Cancel()
			end

			tween = TweenService:Create(part, info, { CFrame = target })
			tween:Play()
			tweening = true

			tween.Completed:Connect(function()
				tweening = false
			end)
		end

		lastCF = target
	end

	setStartPos()

	while task.wait() do
		followCamera()
	end
end

UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.M then
		if not uiOpen then
			uiOpen = true

			local uiPart = RS:WaitForChild("UI"):Clone()
			uiPart.Parent = workspace

			-- start collapsed
			local originalSize = uiPart.Size
			uiPart.Size = Vector3.new(originalSize.X, 0, originalSize.Z)

			activeUI = uiPart

			-- grow open
			TweenService:Create(uiPart, TweenInfo.new(0.5), { Size = originalSize }):Play()

			-- run texture animations
			for _, child in ipairs(uiPart:GetChildren()) do
				if child:IsA("Texture") then
					local fx = RS.AnimateUI:Clone()
					fx.Enabled = true
					fx.Parent = child

					task.spawn(function()
						while child.Parent do
							if child.Name == "Uno" then
								child.OffsetStudsU += 0.01
								child.OffsetStudsV += 0.01
							elseif child.Name == "Dos" then
								child.OffsetStudsU -= 0.01
								child.OffsetStudsV += 0.01
							end
							task.wait()
						end
					end)
				end
			end

			player.PlayerGui.StatusUI.Adornee = uiPart

			attachUI(uiPart)

		else
			uiOpen = false
			local target = player.PlayerGui.StatusUI.Adornee

			if target then
				local shrink = TweenService:Create(
					target,
					TweenInfo.new(0.5),
					{ Size = Vector3.new(target.Size.X, 0, target.Size.Z) }
				)

				shrink:Play()
				shrink.Completed:Wait()

				target:Destroy()
			end
		end
	end
end)

local function cleanupUI()
	if activeUI then
		activeUI:Destroy()
		activeUI = nil
		uiOpen = false
	end
end

player.CharacterAdded:Connect(cleanupUI)
