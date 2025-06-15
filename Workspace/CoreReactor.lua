-- CoreReactor.lua
-- Handles core reactor temperature, state, and meltdown logic

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CoreStatusChanged = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("CoreStatusChanged")

local CoreReactor = {}

local temperature = 20 -- Initial temperature
local maxTemperature = 100
local meltdownThreshold = 90
local meltdownStarted = false

local function updateCoreStatus()
    if temperature >= meltdownThreshold and not meltdownStarted then
        meltdownStarted = true
        CoreStatusChanged:FireAllClients("Meltdown")
        print("[CoreReactor] Meltdown started!")
        -- Additional meltdown logic here
    elseif temperature < meltdownThreshold and meltdownStarted then
        meltdownStarted = false
        CoreStatusChanged:FireAllClients("Normal")
        print("[CoreReactor] Meltdown stopped!")
    end
end

function CoreReactor:IncreaseTemperature(amount)
    temperature = math.min(temperature + amount, maxTemperature)
    updateCoreStatus()
    print("[CoreReactor] Temperature increased to", temperature)
end

function CoreReactor:DecreaseTemperature(amount)
    temperature = math.max(temperature - amount, 0)
    updateCoreStatus()
    print("[CoreReactor] Temperature decreased to", temperature)
end

function CoreReactor:GetTemperature()
    return temperature
end

return CoreReactor
