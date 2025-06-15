-- SuitHandler.lua
-- Client-side script to handle suit equip and removal

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local EquipSuitEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("EquipSuit")
local RemoveSuitEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RemoveSuit")

local PlayerGui = Player:WaitForChild("PlayerGui")

-- Example GUI for suit status
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SuitStatusGUI"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 200, 0, 50)
statusLabel.Position = UDim2.new(0.5, -100, 0, 50)
statusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 24
statusLabel.Text = "Suit: Not Equipped"
statusLabel.Parent = screenGui

-- Listen for suit equip event
EquipSuitEvent.OnClientEvent:Connect(function()
    statusLabel.Text = "Suit: Equipped"
end)

-- Listen for suit removal event
RemoveSuitEvent.OnClientEvent:Connect(function()
    statusLabel.Text = "Suit: Not Equipped"
end)
