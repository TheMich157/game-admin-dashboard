local Players = game:GetService("Players")
local RoleManager = require(script.Parent.RoleManager) -- Uisti sa, že RoleManager je v rovnakom priečinku

Players.PlayerAdded:Connect(function(player)
	-- Leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local role = Instance.new("StringValue")
	role.Name = "Role"
	role.Value = "Scientist" -- default
	role.Parent = leaderstats

	local level = Instance.new("IntValue")
	level.Name = "Level"
	level.Value = 1
	level.Parent = leaderstats

	local xp = Instance.new("IntValue")
	xp.Name = "XP"
	xp.Value = 0
	xp.Parent = leaderstats

	-- Voliteľné: zobraz Access Level v leaderstats
	local access = Instance.new("IntValue")
	access.Name = "AccessLevel"
	access.Value = RoleManager:GetCardLevel("Scientist")
	access.Parent = leaderstats

	-- Aktualizuj Access Level automaticky ak sa zmení role
	role.Changed:Connect(function()
		local newRole = role.Value
		access.Value = RoleManager:GetCardLevel(newRole)
	end)
end)
