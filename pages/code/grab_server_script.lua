local RunService = game:GetService("RunService") --Services
local PhysicsService = game:GetService("PhysicsService")
local DebrisService = game:GetService("Debris")
PhysicsService:RegisterCollisionGroup("Grabbed") --Collision Group Stuff
PhysicsService:RegisterCollisionGroup("NonCollide")
PhysicsService:CollisionGroupSetCollidable("NonCollide", "Grabbed", false)
local remote = game.ReplicatedStorage:WaitForChild("GrabRemote") --Remote Event inside of replicated storage
local state = {} -- per-player data
function setCollisionGroup(group) --Function to use if you dont want something to collide with the grabbed object
	for _, i in ipairs(group:GetChildren()) do
		if i:IsA("BasePart") then
			i.CollisionGroup = "NonCollide"
		end
	end
end
local sounds = require(game.ReplicatedStorage.Sound)
remote.OnServerEvent:Connect(function(plr, action, arg1, arg2) --Fired when the remote is activated
	state[plr] = state[plr] or { --Some OOP for player
		part = nil,
		hl = nil,
		beam = nil,
		sound = nil,
		distance = 6,
		cameraCFrame = nil,
		velocity = Vector3.zero,
	}
	local data = state[plr] --Declares data as the object ^
	if action == "Grab" then --When the user grabs object
		local part = arg1
		local dist = arg2
		if part and part:HasTag("Moveable") then
			data.hl = Instance.new("Highlight") --Makes highlight
			data.hl.FillTransparency = 0.85
			data.hl.FillColor = Color3.fromRGB(61, 194, 255)
			data.hl.OutlineColor = Color3.fromRGB(61, 194, 255)
			data.hl.Parent = part
			data.beam = game.ReplicatedStorage.Beam:Clone() --Makes cool beam
			data.beam.Parent = game.Workspace
			data.sound = Instance.new("Sound")
			data.sound.SoundId = "rbxassetid://6241471712"
			data.sound.Looped = true
			data.sound.Parent = plr.Character.Head
			data.sound.Volume = 0.35
			data.sound:Play()
			local att0 = Instance.new("Attachment",plr.Character:WaitForChild("HumanoidRootPart"))
			local att1 = Instance.new("Attachment",part)
			att0.Orientation = Vector3.new(0,0,-90)
			att1.Orientation = Vector3.new(0,0,-90)
			data.beam.Attachment0 = att0
			data.beam.Attachment1 = att1
			data.part = part
			if not data.part.Anchored then data.part:SetNetworkOwner(plr) end--Helps prevent jittery looks, smoothly running
			data.distance = dist
			data.velocity = Vector3.zero
			if not data.part.Anchored then data.part.CollisionGroup = "Grabbed" end --Collision group so it wont collide with the player
			setCollisionGroup(plr.Character)
		end
	elseif action == "Release" then --When the user drops object
		if data.sound then
			data.sound:Destroy()
			data.sound = nil
		end
		if data.part then
			data.hl:Destroy() --No highlight
			data.hl = nil
			data.beam:Destroy() --No beam
			data.beam = nil
			data.part.CollisionGroup = "Default" --Resets collision group
			if not data.part.Anchored then data.part:SetNetworkOwner(nil) end
		end
		data.part = nil
	elseif action == "Throw" then --When the user throws object
		local power = arg1
		if data.part and not data.part.Anchored then
			data.hl:Destroy() --No higlhight
			data.hl = nil
			data.beam:Destroy() --No beam
			data.beam = nil
			local part = data.part
			data.part = nil
			part.Anchored = true
			part.Anchored = false
			part.AssemblyLinearVelocity = data.cameraCFrame.LookVector * power --Launches the part
			part.CollisionGroup = "Default"
			part:SetNetworkOwner(nil)
			data.sound:Destroy()
			data.sound = nil
		elseif data.part and data.sound then
			
		end
	elseif action == "Anchor" then
		local hovered = arg1
		if data.part then
			local part = data.part
			if data.part.Anchored then
				data.part.Anchored = false
				data.part:SetNetworkOwner(plr.Character)
				data.part.CollisionGroup = "Grabbed"
				sounds.makeAudio(773858658,0.67,2,data.part)
			else
				data.part.Anchored = true
				data.part.CollisionGroup = "Default"
				local anchorParticles = game.ReplicatedStorage.Anchor:Clone()
				anchorParticles.Parent = data.part
				anchorParticles.Enabled = true
				DebrisService:AddItem(anchorParticles,3)
				sounds.makeAudio(315912428,0.67,2,data.part)
				task.spawn(function()
					task.wait(0.5)
					anchorParticles.Enabled = false
					part.AssemblyLinearVelocity = Vector3.new(0,0,0)
					part.AssemblyAngularVelocity = Vector3.new(0,0,0)
				end)
			end
		end
	elseif action == "SetDistance" then --Sets distance of object
		data.distance = arg1

	elseif action == "UpdateCamera" then --Updates the camera position
		data.cameraCFrame = arg1
	end
end)
local stiffness = 18     --How strong the spring pulls
local damping = 5     --How much to slow velocity (no oscillation)
RunService.Heartbeat:Connect(function(dt)
	for plr, data in pairs(state) do
		if data.part and data.cameraCFrame and not data.part.Anchored then
			local char = plr.Character --Checks for character and head
			if not char then continue end
			local head = char:FindFirstChild("Head")
			if not head then continue end
			local target = head.Position + data.cameraCFrame.LookVector * data.distance --Position to go to
			local part = data.part
			local position = part.Position
			local displacement = target - position
			local accel = displacement * stiffness - data.velocity * damping --Calculates the acceleration needed
			data.velocity = data.velocity + accel * dt
			local newPos = position + data.velocity * dt
			part.AssemblyLinearVelocity = (newPos - part.Position) / dt --Moves the grabbed object
		end
	end
end)