-- LockdownUI.lua
-- Client-side script to display lockdown status

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local LockdownStatusEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("LockdownStatus")

local PlayerGui = Player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LockdownUI"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 300, 0, 50)
statusLabel.Position = UDim2.new(0.5, -150, 0, 110)
statusLabel.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 24
statusLabel.Text = "Lockdown: Inactive"
statusLabel.Parent = screenGui

LockdownStatusEvent.OnClientEvent:Connect(function(active)
    if active then
        statusLabel.Text = "Lockdown: ACTIVE"
        statusLabel.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    else
        statusLabel.Text = "Lockdown: Inactive"
        statusLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end
end)
