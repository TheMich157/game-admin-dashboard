-- AchievementSystem.lua
-- Server-side logic to handle achievements

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local AchievementUnlocked = RemoteEvents:WaitForChild("AchievementUnlocked")

-- Define achievements
local Achievements = {
	["FirstLogin"] = {
		Name = "Welcome to Aurelia",
		Description = "Join the game for the first time",
		RewardXP = 25,
	},
	["OpenVault"] = {
		Name = "Access Granted",
		Description = "Open a restricted vault door",
		RewardXP = 50,
	},
	["CoreMeltdown"] = {
		Name = "You Blew It Up",
		Description = "Witness a full meltdown of the Core",
		RewardXP = 100,
	},
}

-- Award achievement if not already earned
local function awardAchievement(player, id)
	if not Achievements[id] then return end

	local statsFolder = player:FindFirstChild("Stats")
	if not statsFolder then return end

	local achieved = statsFolder:FindFirstChild("Ach_" .. id)
	if not achieved then
		achieved = Instance.new("BoolValue")
		achieved.Name = "Ach_" .. id
		achieved.Value = false
		achieved.Parent = statsFolder
	end

	if achieved.Value then return end -- Already earned

	-- Mark as earned
	achieved.Value = true

	-- Add XP reward
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats and leaderstats:FindFirstChild("XP") then
		leaderstats.XP.Value += Achievements[id].RewardXP
	end

	-- Notify client
	AchievementUnlocked:FireClient(player, {
		ID = id,
		Name = Achievements[id].Name,
		Description = Achievements[id].Description,
		XP = Achievements[id].RewardXP
	})

	print("[AchievementSystem] Player", player.Name, "unlocked:", id)
end

-- Handle player join
Players.PlayerAdded:Connect(function(player)
	-- Stats folder to track achievements
	local statsFolder = Instance.new("Folder")
	statsFolder.Name = "Stats"
	statsFolder.Parent = player

	-- leaderstats (XP) for reward system
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local xpValue = Instance.new("IntValue")
	xpValue.Name = "XP"
	xpValue.Value = 0
	xpValue.Parent = leaderstats

	local keycardLevel = Instance.new("IntValue")
	keycardLevel.Name = "KeycardLevel"
	keycardLevel.Value = 1
	keycardLevel.Parent = leaderstats

	-- Grant "FirstLogin"
	awardAchievement(player, "FirstLogin")
end)

-- Public function to be called by other systems
_G.Achievements = {
	Award = awardAchievement
}
