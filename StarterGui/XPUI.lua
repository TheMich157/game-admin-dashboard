-- XPUI.lua
-- Client-side script to display player XP and level

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local PlayerGui = Player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "XPUI"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 50)
mainFrame.Position = UDim2.new(0.5, -100, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Level Label
local levelLabel = Instance.new("TextLabel")
levelLabel.Size = UDim2.new(0.5, 0, 1, 0)
levelLabel.Position = UDim2.new(0, 0, 0, 0)
levelLabel.BackgroundTransparency = 1
levelLabel.TextColor3 = Color3.new(1, 1, 1)
levelLabel.Font = Enum.Font.GothamBold
levelLabel.TextSize = 24
levelLabel.Text = "Level: 1"
levelLabel.Parent = mainFrame

-- XP Label
local xpLabel = Instance.new("TextLabel")
xpLabel.Size = UDim2.new(0.5, 0, 1, 0)
xpLabel.Position = UDim2.new(0.5, 0, 0, 0)
xpLabel.BackgroundTransparency = 1
xpLabel.TextColor3 = Color3.new(1, 1, 1)
xpLabel.Font = Enum.Font.Gotham
xpLabel.TextSize = 24
xpLabel.Text = "XP: 0"
xpLabel.Parent = mainFrame

-- Update function
local function updateXP()
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        local level = leaderstats:FindFirstChild("Level")
        local xp = leaderstats:FindFirstChild("XP")
        if level and xp then
            levelLabel.Text = "Level: " .. tostring(level.Value)
            xpLabel.Text = "XP: " .. tostring(xp.Value)
        end
    end
end

-- Connect to changes
local leaderstats = Player:WaitForChild("leaderstats")
leaderstats.ChildAdded:Connect(updateXP)
leaderstats.ChildChanged:Connect(updateXP)

-- Initial update
updateXP()
