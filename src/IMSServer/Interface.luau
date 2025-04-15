local colServ = game:GetService("CollectionService")
local repStor = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")

local types = require(script.Parent.Types)
local IMSShared = repStor.IMSShared

local Interface = {}

local devices = {}
local foundClasses = {}

local playerInit = {}

local function stateUpdated(device:types.Device<any>, newState:any)
    IMSShared.DeviceStateUpdate:FireAllClients(device.model, device.className, newState)
end

local function stateKeyUpdated(device:types.Device<any>, newStateKey:{[string]:any})
    IMSShared.DeviceStateKeyUpdate:FireAllClients(device.model, device.className, newStateKey)
end

function Interface.Version():string
    return "25.2"
end

function Interface.Init()
    print(`Initializing Neo-IMS Version {Interface.Version()}`)

    if not repStor.Signal then
        error("[Neo-IMS]: Failed to find signal library under 'ReplicatedStorage.Signal'.")
        return
    elseif not repStor.Signal:IsA("ModuleScript") then
        error("[Neo-IMS]: 'ReplicatedStorage.Signal' is not a module script!")
        return
    end

    local deviceFolders = {"Devices"}

    for _,folder in pairs(deviceFolders) do
        for _,class in pairs(script.Parent[folder]:GetChildren()) do
            if not class:IsA("ModuleScript") then continue end

            -- Ensure we only load a device class once
            if table.find(foundClasses, class.Name) then continue end
            table.insert(foundClasses, class.Name)

            local deviceClass = require(class)

            local count = 0
            for _,device in pairs(colServ:GetTagged(class.Name)) do
                --TODO: Implement Complex Interactables

                -- print a warning for duplicate devices and skip them
                -- but not for devices named "INOP" (can be used for unimplemented devices)
                if devices[device.Name] and not string.find(device.Name, "INOP") then
                    warn("[Neo-IMS]: Device with name \"" .. device.Name "\" already exists. Skipping.")
                    continue
                end

                local initialState = nil

                if device:FindFirstChild("InitialState") then 
                    if device.InitialState:IsA("Folder") then
                        initialState = {}
                        for _,item in pairs(device.InitialState:GetChildren()) do
                            -- TODO: make this recursive so subfolders can be a thing
                            if item:IsA("Folder") then
                                continue
                            end

                            initialState[item.Name] = item.Value
                        end
                    else
                        initialState = device.InitialState.Value
                    end
                end

                local deviceInstance = deviceClass.new(device, initialState) :: types.Device<T>
                deviceInstance.className = class.Name

                count += 1

                devices[deviceInstance.name] = deviceInstance

                deviceInstance.OnStateChanged:Connect(function(state)
                    stateUpdated(deviceInstance, state)
                end)

                deviceInstance.OnStateKeyChanged:Connect(function(stateKey)
                    stateKeyUpdated(deviceInstance, stateKey)
                end)
            end
            print("[Neo-IMS]: FOUND " .. count .. " DEVICES OF CLASS \"" .. class.name .. "\"!")
        end
    end
end

function Interface.GetDevice(name:string):types.Device<any> | nil
    return devices[name]
end

function Interface.GetDevicesOfClass(class:string):{types.Device<any>}
    local array = {}

    for _,a in pairs(devices) do
        if a.className == class then
            table.insert(array, a)
        end
    end

    return array
end

function Interface.SendMessage(deviceName:string, player:Player, msg:{[string]:any}):boolean
    local device = Interface.GetDevice(deviceName)

    if device == nil then
        error("[Neo-IMS]: Unable to send message to device \"" .. deviceName .. "\", because it could not be found.")
        return false
    end

    local state = device:RecieveMessage(player, msg)

    if state then
        device.OnMessageRecieved:Fire()
    end

    return state
end

IMSShared.SendDeviceMessage.OnServerEvent:Connect(function(player:Player, deviceName:string, msg:{[string]:any})
    Interface.SendMessage(deviceName, player, msg)
end)

IMSShared.RequestDeviceInit.OnServerInvoke = function(player:Player):{[string]:{className:string, model:Model, state:any}}
    -- ensure we only send an init once to minimize strain on the server
    -- (i.e. due to someone spamming the event)
    if table.find(playerInit, player) then
        return nil
    end
    table.insert(playerInit, player)

    local array = {}

    for name,inst in pairs(devices) do
        array[name] = 
        {
            className = inst.className,
            model = inst.model,
            state = inst.state
        }
    end

    return array
end

-- ensure a player can re-recieve an init event if they rejoin
players.PlayerRemoving:Connect(function(player:Player)
    table.remove(playerInit, table.find(playerInit, player))
end)

return Interface