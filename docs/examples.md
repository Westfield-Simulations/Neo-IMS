---
sidebar_position: 5
---

# Examples

## Indicator Light

### Server Side

An indicator light only requires the basic server side script. The state is a **Basic State** of type **boolean**.

```lua title="ServerScriptService.IMSServer.Device.Indicator"
local types = require(script.Parent.Parent.Types)
local device = require(script.Parent.Bases.Device)

local Module = {}
Module.__index = Module
setmetatable(Module, device)

function Module.new(model:Model, initialState:boolean):types.Device<boolean>
	if initialState ~= nil and type(initialState) ~= "boolean" then
		error("[INTERACTION SYSTEM]: InitialState type for Indicator must be boolean!")
		return nil
	end
	
	local self = device.new(model, initialState or false) -- "false" is the default value
	setmetatable(self, Module)

	return self
end

return Module
```

### Client Side

The client side is also very simple.
On an update, the light's material will get set to neon or glass depending on whether or not the state is set to true.

```lua title="StarterPlayer.StarterPlayerScripts.IMSClient.Devices.Indicator"
local module = {}

function module.Init(deviceModel:Model, deviceState:boolean)
    -- Run update to ensure the initial device state gets displayed correctly
    module.Update(deviceModel, deviceState)
end

function module.Update(deviceModel:Model, deviceState:boolean)
    deviceModel.light.Material = deviceState and Enum.Material.Neon or Enum.Material.Glass
end

return module
```

---

## Button

### Server Side

Whenever the server recievs a message from the client, it updates the state accordingly:

```lua title="ServerScriptService.IMSServer.Device.Button"
local types = require(script.Parent.Parent.Types)
local device = require(script.Parent.Bases.Device)

local signal = require(game:GetService("ReplicatedStorage").Signal)

local Module = {}
Module.__index = Module
setmetatable(Module, device)

function Module.new(model:Model, initialState:boolean):types.Device<boolean>
	-- Standard init function
end

function Module.RecieveMessage(self:types.Device<boolean>, player:Player, msg:{[string]:any}):boolean
    if msg["EVENT"] == "click" then
        self:SetState(true)

        return true -- message was processed successfully
    elseif msg["EVENT"] == "release" then
        self:SetState(false)

        return true -- message was processed successfully
    end

    return false -- message was not processed successfully
end 

return Module
```

### Client Side

The client sends a message whenever the player clicks or releases the button and updates the model (by changing the button material) according to the device state.

```lua title="StarterPlayer.StarterPlayerScripts.IMSClient.Devices.Button"
local repStor = game:GetService("ReplicatedStorage")

local module = {}

function module.Init(deviceModel:Model, deviceState:boolean)
    deviceModel:WaitForChild("Button").DragDetector.DragStart:Connect(function()
        repStor.IMSShared.SendDeviceMessage:FireServer(deviceModel.Name, {["EVENT"]="click"})
    end)
    deviceModel:WaitForChild("Button").DragDetector.DragEbd:Connect(function()
        repStor.IMSShared.SendDeviceMessage:FireServer(deviceModel.Name, {["EVENT"]="release"})
    end)
end

function module.Update(deviceModel:Model, deviceState:boolean)
    local button = deviceModel:WaitForChild("Button")

    if deviceState == true then
        button.Material = Enum.Material.Neon
    else
        button.Material = Enum.Material.SmoothPlastic
    end
end

return module
```