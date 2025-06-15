-- AdminPanelUI.lua
-- Client-side script for admin panel UI

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local AdminCommand = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AdminCommand")

local PlayerGui = Player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminPanelGUI"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 600)
mainFrame.Position = UDim2.new(1, -410, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.AnchorPoint = Vector2.new(1, 0.5)
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "Admin Panel"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.Parent = mainFrame

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.Parent = mainFrame

closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

-- Example Button: Trigger Lockdown
local lockdownButton = Instance.new("TextButton")
lockdownButton.Size = UDim2.new(1, -20, 0, 40)
lockdownButton.Position = UDim2.new(0, 10, 0, 70)
lockdownButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
lockdownButton.Text = "Trigger Lockdown"
lockdownButton.TextColor3 = Color3.new(1, 1, 1)
lockdownButton.Font = Enum.Font.Gotham
lockdownButton.TextSize = 20
lockdownButton.Parent = mainFrame

lockdownButton.MouseButton1Click:Connect(function()
    AdminCommand:FireServer("Lockdown")
end)

-- Show the admin panel when player is an admin (example check)
local function checkAdmin()
    -- Replace with actual admin check logic
    return true
end

if checkAdmin() then
    screenGui.Enabled = true
else
    screenGui.Enabled = false
end
