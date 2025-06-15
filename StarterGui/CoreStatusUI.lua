-- CoreStatusUI.lua
-- Client-side script to display core reactor status

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local CoreStatusChanged = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("CoreStatusChanged")

local PlayerGui = Player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoreStatusUI"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 300, 0, 50)
statusLabel.Position = UDim2.new(0.5, -150, 0, 160)
statusLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 24
statusLabel.Text = "Core Status: Offline"
statusLabel.Parent = screenGui

CoreStatusChanged.OnClientEvent:Connect(function(status, countdown)
    if countdown then
        statusLabel.Text = "Core Status: " .. status .. " (" .. tostring(countdown) .. "s)"
    else
        statusLabel.Text = "Core Status: " .. status
    end
end)
