-- SuitUI.lua
-- Client-side script to display suit status

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

local PlayerGui = Player:WaitForChild("PlayerGui")

local EquipSuitEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("EquipSuit")
local RemoveSuitEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RemoveSuit")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SuitUI"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 200, 0, 50)
statusLabel.Position = UDim2.new(0.5, -100, 0, 70)
statusLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 24
statusLabel.Text = "Suit: Not Equipped"
statusLabel.Parent = screenGui

EquipSuitEvent.OnClientEvent:Connect(function()
    statusLabel.Text = "Suit: Equipped"
end)

RemoveSuitEvent.OnClientEvent:Connect(function()
    statusLabel.Text = "Suit: Not Equipped"
end)
