-- AchievementUIHandler.lua
-- Klientský skript, ktorý zobrazuje oznámenie o odomknutí achievementu

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local AchievementUnlocked = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AchievementUnlocked")

-- Referencia na GUI (musíš ho vytvoriť v StarterGui)
local screenGui = Player:WaitForChild("PlayerGui"):WaitForChild("AchievementGUI")
local template = screenGui:WaitForChild("Template")

AchievementUnlocked.OnClientEvent:Connect(function(data)
	if not data then return end

	local clone = template:Clone()
	clone.Visible = true
	clone.Parent = screenGui
	clone.Title.Text = data.Name
	clone.Desc.Text = data.Description
	clone.XPLabel.Text = "+ " .. tostring(data.XP) .. " XP"

	-- Vizuálny efekt (fade in + fade out)
	clone:TweenPosition(UDim2.new(0.5, -150, 0.15, 0), "Out", "Quad", 0.5, true)
	wait(4)
	clone:TweenPosition(UDim2.new(0.5, -150, -0.2, 0), "In", "Quad", 0.5, true)
	wait(0.6)
	clone:Destroy()
end)
