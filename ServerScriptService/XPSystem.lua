local RoleManager = require(script.Parent:WaitForChild("RoleManager"))

local XPSystem = {}

-- Koľko XP je potrebné na ďalší level
function XPSystem:GetXPNeeded(level)
	return level * 100 -- napr. Lvl 1 → 100 XP, Lvl 2 → 200 XP, ...
end

-- Pridaj XP hráčovi
function XPSystem:AddXP(player, amount)
	if not player:FindFirstChild("leaderstats") then return end
	local stats = player.leaderstats

	local xp = stats:FindFirstChild("XP")
	local level = stats:FindFirstChild("Level")
	local role = stats:FindFirstChild("Role")

	if not (xp and level and role) then return end

	local currentXP = xp.Value
	local currentLevel = level.Value
	local maxLevel = RoleManager:GetMaxLevel(role.Value)

	-- Pridaj XP
	currentXP += amount
	xp.Value = currentXP

	-- Level-up loop (ak hráč získal viac XP naraz)
	while currentXP >= XPSystem:GetXPNeeded(currentLevel) and currentLevel < maxLevel do
		currentXP -= XPSystem:GetXPNeeded(currentLevel)
		currentLevel += 1
		level.Value = currentLevel
		xp.Value = currentXP

		print(player.Name .. " leveled up to Level " .. currentLevel)

		-- Voliteľne: Zavolaj ďalšie efekty (uniforma, notifikácia, zvuk...)
		XPSystem:OnLevelUp(player, currentLevel)
	end
end

-- Voliteľná funkcia pri level-up
function XPSystem:OnLevelUp(player, newLevel)
	-- napríklad zmeniť uniformu, prehrať zvuk, zobraziť notifikáciu
	local role = RoleManager:GetPlayerRole(player)
	local color = RoleManager:GetRoleColor(role)

	-- Príklad: zmeniť farbu hráča
	if player.Character and player.Character:FindFirstChild("Shirt") then
		player.Character.Shirt.ShirtTemplate = "rbxassetid://123456789" -- zmeň na ID pre nový rank
	end
end

-- Overí, či má hráč právo pridať XP (napr. admin)
function XPSystem:CanGiveXP(player)
	return RoleManager:CanGrantXP(player)
end

return XPSystem
