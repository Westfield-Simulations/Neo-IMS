--!strict

local types = require(script.Parent.Parent.Parent.Types)
local signal = require(game:GetService("ReplicatedStorage").Signal)

local Device = {}
Device.__index = Device

function Device.new<T>(model:Model, initialState:T):types.Device<T>
    local self = {} :: types.Device<T>
    setmetatable(self :: {}, Device)

    self.name = model.Name
    self.model = model
    self.state = initialState
    self.OnStateChanged = signal.new()
    self.OnStateKeyChanged = signal.new()
    self.OnMessageRecieved = signal.new()

    return self
end

function Device.GetState<T>(self:types.Device<T>):T
    return self.state
end

function Device.SetState<T>(self:types.Device<T>, newState:T):boolean
    if self.state == newState then
        return false
    end

    if type(self.state) ~= type(newState) then
        warn("[Neo-IMS]: Device state of device \"" .. self.name .. "\" cannot be changed to \"" .. tostring(newState) .. "\".")
        return false
    end

    self.state = newState

    self.OnStateChanged:Fire(newState)

    return true
end

function Device.SetStateKey<T>(self:types.Device<T>, stateKey:{[string]:any}):boolean
    if type(self.state) ~= "table" then
        error("[Neo-IMS]: Cannot set StateKey of device \"" .. self.name .. "\" because its state is not a table.")
    end

    local changed = false
    for key, val in pairs(stateKey) do
        if key == nil then
            error("[Neo-IMS]: Key passed to Device:SetStateKey for device \"" .. self.name .. "\" is nil.")
        elseif self.state[key] == nil then
            error("[Neo-IMS]: Failed to find statekey \"" .. key .. "\" of device \"" .. self.name .. "\".")
        end

        if type(val) == "table" then
            self.state[key] = val
            changed = true
            continue
        end

        if self.state[key] ~= val then
            self.state[key] = val
            changed = true 
        end
    end

    if changed then
        self.OnStateChanged:Fire(self.state)
    end
    return changed
end

function Device.RecieveMessage<T>(self:types.Device<T>, player:Player, msg:{[string]:any}):boolean
    return false
end

return Device