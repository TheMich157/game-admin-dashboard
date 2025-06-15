-- RoleManager.lua
-- Správa rolí, rankov a prístupových úrovní

local RoleManager = {}

-- Konfigurácia rolí
RoleManager.Roles = {
	["Scientist"] = {
		MaxLevel = 2,
		CardLevel = 2,
		Color = Color3.fromRGB(85, 170, 255),
	},
	["Security"] = {
		MaxLevel = 3,
		CardLevel = 3,
		Color = Color3.fromRGB(255, 85, 85),
	},
	["Commander"] = {
		MaxLevel = 5,
		CardLevel = 4,
		Color = Color3.fromRGB(255, 255, 127),
	},
	["Maintenance"] = {
		MaxLevel = 2,
		CardLevel = 2,
		Color = Color3.fromRGB(170, 170, 170),
	},
	["Admin"] = {
		MaxLevel = 6,
		CardLevel = 5,
		Color = Color3.fromRGB(255, 255, 255),
	},
	["Owner"] = {
		MaxLevel = 10,
		CardLevel = 6,
		Color = Color3.fromRGB(255, 0, 255),
	},
	["Moderator"] = {
		MaxLevel = 5,
		CardLevel = 4,
		Color = Color3.fromRGB(150, 255, 150),
	},
}

-- Získa rolu hráča
function RoleManager:GetPlayerRole(player)
	if player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Role") then
		return player.leaderstats.Role.Value
	end
	return "Unknown"
end

-- Získa aktuálny rank hráča
function RoleManager:GetPlayerLevel(player)
	if player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Level") then
		return player.leaderstats.Level.Value
	end
	return 0
end

-- Vráti maximálny level pre danú rolu
function RoleManager:GetMaxLevel(role)
	local data = self.Roles[role]
	return data and data.MaxLevel or 1
end

-- Vráti prístupovú kartu pre danú rolu
function RoleManager:GetCardLevel(role)
	local data = self.Roles[role]
	return data and data.CardLevel or 1
end

-- Vráti farbu pre danú rolu
function RoleManager:GetRoleColor(role)
	local data = self.Roles[role]
	return data and data.Color or Color3.fromRGB(255, 255, 255)
end

-- Nastaví rolu hráčovi
function RoleManager:SetPlayerRole(player, role)
	if not self.Roles[role] then return false end

	if player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Role") then
		player.leaderstats.Role.Value = role
		return true
	end
	return false
end

-- Overenie, či hráč môže prideľovať XP
function RoleManager:CanGrantXP(player)
	local role = self:GetPlayerRole(player)
	return role == "Admin" or role == "Owner"
end

-- Získaj úroveň karty hráča priamo
function RoleManager:GetPlayerCardLevel(player)
	local role = self:GetPlayerRole(player)
	return self:GetCardLevel(role)
end

-- Kontrola, či má hráč prístup k určitej dverovej úrovni
function RoleManager:HasCardAccess(player, requiredLevel)
	local cardLevel = self:GetPlayerCardLevel(player)
	return cardLevel >= requiredLevel
end

return RoleManager
