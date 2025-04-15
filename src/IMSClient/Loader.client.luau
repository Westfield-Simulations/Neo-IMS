local repStor = game:GetService("ReplicatedStorage")

if not game:IsLoaded() then game.Loaded:Wait() end

task.wait(5) -- For some reason if we don't wait before doing anything, information about device models will randomly be sent to the shadow realm

print("Initializing Neo-IMS Client Side")

if not repStor.Signal then
    error("[Neo-IMS]: Failed to find signal library under 'ReplicatedStorage.Signal'.")
    return
elseif not repStor.Signal:IsA("ModuleScript") then
    error("[Neo-IMS]: 'ReplicatedStorage.Signal' is not a module script!")
    return
end

local devices = {}

local function reloadDevices()
    table.clear(devices)
    for _,a in pairs(script.Parent.Parent.IMSCDevices:GetChildren()) do
        if not a:IsA("ModuleScript") then
            continue
        end

        -- If we're in VR and the device has a VR implementation load that instead.
        if game.VRService.VREnabled and script.Parent.Devices.VR:FindFirstChild(a.Name) then
            devices[a.Name] = require(script.Parent.Devices.VR[a.Name])
            continue
        end

        devices[a.Name] = require(a)
    end
end
reloadDevices()

--TODO: add the ability to swap between VR and normal implementation mid-game

local isInit = false

repStor.IMSShared.DeviceStateUpdate.OnClientEvent:Connect(function(deviceModel:Model, className:string, deviceState:any)
    if not isInit then
        return
    end
    if devices[className .. "C"] == nil then
        -- This warning was a horrible idea
        --warn("[Neo-IMS]: Server attempted to update device \"" .. className .. "\" which is not defined on this client. Are you missing a device implementation?")
        return
    end
    devices[className .. "C"].Update(deviceModel, deviceState)
end)

local devicesInit = repStor.IMSShared.RequestDeviceInit:InvokeServer() :: {[string]:{className:string, model:Model, state:any}}
for i,a in pairs(devicesInit) do
    if devices[a.className .. "C"] == nil then
        warn(`[Neo-IMS]: Device of type {a.className} does not have a client implementation.`)
        continue
    end
    if devices[a.className .. "C"].Init ~= nil then
        devices[a.className .. "C"].Init(a.model, a.state)
    end
end

isInit = true