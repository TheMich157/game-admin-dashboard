-- Core control system code here
-- CoreControl.lua
-- Server-side control of Core status and meltdown handling

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local UpdateCoreStatus = RemoteEvents:WaitForChild("UpdateCoreStatus")
local TriggerAlarm = RemoteEvents:WaitForChild("TriggerAlarm")

-- Core stavové módy
local CoreStates = {
	"Normal",
	"Warning",
	"Overheat",
	"Critical",
	"Meltdown",
	"Destroyed"
}

-- Počiatočný stav
local currentState = "Normal"
local meltdownTimer = nil
local meltdownTime = 60 -- sekúnd do zničenia

-- Funkcia na nastavenie nového stavu
local function setCoreState(newState)
	if currentState == newState then return end
	currentState = newState
	print("[CoreControl] Stav core sa zmenil na:", newState)

	-- Vizuálna aktualizácia cez klienta
	UpdateCoreStatus:FireAllClients(newState)

	-- Zvukové efekty a alarmy
	if newState == "Warning" then
		TriggerAlarm:FireAllClients("Warning")
	elseif newState == "Overheat" then
		TriggerAlarm:FireAllClients("Overheat")
	elseif newState == "Critical" then
		TriggerAlarm:FireAllClients("Critical")
	elseif newState == "Meltdown" then
		handleMeltdown()
	elseif newState == "Destroyed" then
		resetFacility()
	end
end

-- Odštartuje meltdown countdown
local function startMeltdown()
	if meltdownTimer then return end

	setCoreState("Meltdown")
	print("[CoreControl] Meltdown initiated. Map will be destroyed in", meltdownTime, "seconds.")

	local t = meltdownTime
	meltdownTimer = task.spawn(function()
		while t > 0 do
			wait(1)
			t -= 1
			UpdateCoreStatus:FireAllClients("Meltdown", t)
		end
		destroyMap()
	end)
end

-- Zniči mapu
function destroyMap()
	print("[CoreControl] Destroying map...")
	TriggerAlarm:FireAllClients("Destruction")
	
	-- Skrytie/destroy častí mapy
	for _, part in pairs(Workspace:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "Core" then
			part:Destroy()
		end
	end

	setCoreState("Destroyed")
end

-- Regenerácia mapy po zničení
function resetFacility()
	print("[CoreControl] Regenerating map...")
	task.wait(5)

	local mapClone = ReplicatedStorage:WaitForChild("MapBackup"):Clone()
	mapClone.Parent = Workspace
	setCoreState("Normal")
	meltdownTimer = nil
end

-- Prístup pre iné skripty
_G.CoreControl = {
	SetState = setCoreState,
	StartMeltdown = startMeltdown,
	GetState = function() return currentState end
}
