local colServ = game:GetService("CollectionService")
local repStor = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local runServ = game:GetService("RunService")
local httpServ = game:GetService("HttpService")

local types = require(script.Parent.Types)
local IMSShared = repStor.IMSShared


--- @class Interface
--- @server
--- Class that acts as the serverside loader for Neo-IMS.
--- This class is responsible for loading all devices, handling/validating info that gets sent to/from the client, and providing instances of devices for use in other scripts (i.e. simulation).
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

--- Returns the current version of Neo-IMS as a string.
---
--- @return string -- Returns the current version of Neo-IMS
function Interface.Version():string
    return "25.2"
end

--- Initializes Neo-IMS and loads all devices tagged with a valid class name.
---
--- @error [Neo-IMS]: Failed to find signal library under 'ReplicatedStorage.Signal'. -- This error is thrown if you failed to provide a signal library for Neo-IMS to use.
--- @error [Neo-IMS]: 'ReplicatedStorage.Signal' is not a module script! -- Neo-IMS expects a signal library that has a single module script as an interface.
--- @error [Neo-IMS]: Device with name [...] already exists. Skipping. -- Neo-IMS cannot load multiple devices with the same name. Only one instance will be loaded.
function Interface.Init()
    print(`Initializing Neo-IMS Version {Interface.Version()}`)

    if runServ:IsStudio() then
        print("[Neo-IMS]: Checking for updates..")

        local url = "https://api.github.com/repos/Bloxinghouse-Electric-Corporation/Neo-IMS/releases/latest"
        local response = httpServ:GetAsync(url)
        local data = httpServ:JSONDecode(response)
        local majorUpstream = tonumber(string.split(data.tag_name, ".")[1]:sub(2, -1))
        local minorUpstream = tonumber(string.split(data.tag_name, ".")[2])

        local major = tonumber(string.split(Interface.Version(), ".")[1])
        local minor = tonumber(string.split(Interface.Version(), ".")[2])

        if (minorUpstream > minor and majorUpstream == major) or majorUpstream > major then
            warn(`[Neo-IMS]: New update is available! Current version: {Interface.Version()}, Available Version: {data.tag_name}.`)
        else
            print("[Neo-IMS]: Newest version installed!")
        end
    end

    if not repStor.Signal then
        error("[Neo-IMS]: Failed to find signal library under 'ReplicatedStorage.Signal'.")
        return
    elseif not repStor.Signal:IsA("ModuleScript") then
        error("[Neo-IMS]: 'ReplicatedStorage.Signal' is not a module script!")
        return
    end

    local deviceFolders = {"IMSSDevices"}

    for _,folder in pairs(deviceFolders) do
        for _,class in pairs(script.Parent.Parent[folder]:GetChildren()) do
            if not class:IsA("ModuleScript") then continue end

            -- Ensure we only load a device class once
            if table.find(foundClasses, class.Name) then continue end
            table.insert(foundClasses, class.Name)

            local deviceClass = require(class)

            local count = 0
            for _,device in pairs(colServ:GetTagged(class.Name)) do
                if device.Parent ~= nil then
					if device.Parent:HasTag("ComplexInteractable") then
						device.Name = device.Parent.Name .. " " .. device.Name
					elseif device.Parent.Parent ~= nil and device.Parent:IsA("SurfaceGui") and device.Parent.Parent:HasTag("ComplexInteractable") then
						device.Name = device.Parent.Parent.Name .. " " .. device.Name
					end
				end

                -- print a warning for duplicate devices and skip them
                -- but not for devices named "INOP" (can be used for unimplemented devices)
                if devices[device.Name] and not string.find(device.Name, "INOP") then
                    warn("[Neo-IMS]: Device with name \"" .. device.Name .. "\" already exists. Skipping.")
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

--- Returns an instance of a device if it exists.
---
--- @param name string -- The name of the device as it is in workspace.
--- @return Types.Device<any> | nil -- The instance of the device, or nil if it does not exist.
function Interface.GetDevice(name:string):types.Device<any> | nil
    return devices[name]
end

--- Returns a table of all devices of a certain class.
---
--- @param class string -- The class to look for
--- @return {Types.Device<any>} -- The array of devices
function Interface.GetDevicesOfClass(class:string):{types.Device<any>}
    local array = {}

    for _,a in pairs(devices) do
        if a.className == class then
            table.insert(array, a)
        end
    end

    return array
end

--- Sends a message from a client to a device to handle. This is usually only used internally.
--- @private
--- @param deviceName string -- The name of the device to target as it is in Workspace.
--- @param player Player -- The player to send the message from
--- @param msg {[string]:any} -- The message(s) to pass to the device
--- @return boolean -- Whether or not the message was processed successfully.
---
--- @error [Neo-IMS]: Unable to send message to device [...], because it could not be found. -- The device specified in deviceName does not exist or did not load.
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