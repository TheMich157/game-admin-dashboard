-- KeycardDoors.lua
-- Handles keycard door access control and locking mechanism

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local AccessRequest = RemoteEvents:WaitForChild("AccessRequest")

local AccessManager = require(game.ServerScriptService:WaitForChild("AccessManager"))

-- Function to handle player attempting to open a door
local function onDoorTouched(player, door)
    if not player or not door then return end
    local hasAccess = AccessManager:CheckAccess(player, door)
    if hasAccess then
        print("[KeycardDoors] Access granted to", player.Name, "for door", door.Name)
        -- Unlock door logic here
        door:SetAttribute("Locked", false)
    else
        print("[KeycardDoors] Access denied to", player.Name, "for door", door.Name)
        -- Lock door logic here
        door:SetAttribute("Locked", true)
    end
end

-- Connect door touch events (example)
for _, door in pairs(Workspace:GetChildren()) do
    if door:IsA("Model") and door:FindFirstChild("RequiredAccessLevel") then
        door.Touched:Connect(function(hit)
            local player = Players:GetPlayerFromCharacter(hit.Parent)
            if player then
                onDoorTouched(player, door)
            end
        end)
    end
end

return {}
