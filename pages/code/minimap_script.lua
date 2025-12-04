local plr = game.Players.LocalPlayer
local char = plr.Character
local RunService = game:GetService("RunService")
local aspectRatio = 67
local distance = 25
local counter = 0
local vert = 0
task.spawn(function()
    RunService.Heartbeat:Connect(function()
        task.wait(0.1)
        local rot = char:WaitForChild("HumanoidRootPart").Orientation.Y
        script.Parent.Plr.Rotation = rot - 180
    end)
end)
for a = 1, aspectRatio^2, 1 do
    local piece = Instance.new("Frame",script.Parent)
    piece.BackgroundTransparency = 0.1
    piece.Size = UDim2.new((1/aspectRatio),0,(1/aspectRatio),0)
    piece.Position = UDim2.new((1/aspectRatio)*counter,0,(1/aspectRatio)*vert,0)
    piece.Name = "Piece:X"..counter.."Y"..vert
    piece.BorderSizePixel = 0
    local currentCount = counter
    local currentVert = vert
    task.spawn(function()
        RunService.Heartbeat:Connect(function()
            task.wait(0.01)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            raycastParams.FilterDescendantsInstances = {char}
            local ray = workspace:Raycast(char.HumanoidRootPart.Position + Vector3.new((distance/aspectRatio)*currentCount - (distance/2),100,(distance/aspectRatio)*-currentVert + (distance/2)), Vector3.new(char.HumanoidRootPart.Position.X, -1000, char.HumanoidRootPart.Position.Z), raycastParams)
            if ray then
                piece.BackgroundColor3 = ray.Instance.Color
            else
                piece.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            end
        end)
    end)
    counter += 1
    if counter >= aspectRatio then
        counter = 0
        vert += 1
    end
end