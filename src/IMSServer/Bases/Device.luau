--!strict

local types = require(script.Parent.Parent.Types)
local signal = require(game:GetService("ReplicatedStorage").Signal)

--- @class Device
--- @server
---
--- The base class for all serversided devices in Neo-IMS.
local Device = {}
Device.__index = Device

--- @prop name string
--- @within Device
--- The name of the device as it is in Workspace

--- @prop model Model
--- @within Device
--- The model of the device in Workspace

--- @prop state T
--- @within Device
--- The current state of the device

--- Create a new instance of a device. This is automatically done by [Interface].
--- @private
--- @param model Model -- The model of the device in Workspace
--- @param initialState T -- Initial value to set Device.state to.
--- @return Types.Device<T> -- The instance of this class.
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

--- Returns the current state of the device.
---
--- @param self Types.Device<T>
--- @return T -- The current state of the device.
function Device.GetState<T>(self:types.Device<T>):T
    return self.state
end


--- Sets the current state of the device.
---
--- @param self Types.Device<T>
--- @param newState T -- The new state to set
--- @return boolean -- Whether or not the state change was successful.
--- @error [Neo-IMS]: Device state of device [...] cannot be changed to [...]. -- The types of the old device state and the new state do not match.
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


--- Sets the current stateKey (substate) of the device.
---
--- @param self Types.Device<T>
--- @param stateKey {[string]:any} -- The new stateKey to set
--- @return boolean -- Whether or not the state change was successful.
--- @error [Neo-IMS]: Cannot set StateKey of device [...] because its state is not a table. -- If the device was not initialized with a Complex State you cannot set a substate.
--- @error [Neo-IMS]: Key passed to Device:SetStateKey for device [...] is nil. -- A value was passed with a nil key.
--- @error [Neo-IMS]: Failed to find statekey [...] of device [...]. -- Attempted to set a StateKey which does not exist on the device.
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

--- Handles messages sent by [Interface]. This should not be manually called, but instead only overriden for custom device implementations.
--- @private
--- @param self Types.Device<T>
--- @param player Player -- The player who sent the message.
--- @param msg {[string]:any} -- The message.
--- @return boolean -- Whether or not handling the message was successful.
function Device.RecieveMessage<T>(self:types.Device<T>, player:Player, msg:{[string]:any}):boolean
    return false
end

return Device