---
sidebar_position: 2
---

# Server Side Programming

## Device Initialization

Server Side device modules are stored within the *ServerScriptService.IMSSDevices* folder. These modules are automatically loaded by the system as explained in [Introduction](./intro.md#server-side).

The most basic form of a server module looks like this:

```lua title="ServerScriptService.IMSSDevices.Test"
local types = require(script.Parent.Parent.IMSServer.Types)
local device = require(script.Parent.Parent.IMSServer.Bases.Device)

local Module = {}
Module.__index = Module
setmetatable(Module, device)

function Module.new(model:Model, initialState:boolean):types.Device<boolean> -- update "boolean" here to the correct type
	if initialState ~= nil and type(initialState) ~= "boolean" then -- update "boolean" here to the correct type
		error("[INTERACTION SYSTEM]: InitialState type for Module must be boolean!") -- update "boolean" here to the correct type
		return nil
	end
	
	local self = device.new(model, initialState or false) -- "false" is the default value
	setmetatable(self, Module)

	return self
end

return Module
```

The code above does the following in order:
When the module gets initialized by the Interface:
1. Ensure the initial state passed by the Interface is a valid type for this device or if it is nil, throw and error if it is neither.
2. Instantiate the base device class with the physical device model in the game world and the initial state or set it to a default value if initialState is nil.
3. Return a reference to the device.

:::note

Most of the time, this default initialization code does **NOT** need to be altered aside from changing the types and default value to match your device.

In future versions of Neo-IMS we plan on simplifying this by providing a default init function.

:::

This `Module.new()` function is the only requirement for a valid server side script. The programmer is responsible for further event handling themselves. (Examples are covered later in the docs.)

## Referencing

To get a reference to a device on the server for usage in other scripts (i.e. within the simulation), the `Interface.GetDevice(name)` function is used.

The name of the model in workspace must be passed to this function.
If the device exists, a reference to it will be returned, otherwise the Interface will return nil.
**If multiple devices of the same name exist, only one of them will be functional.**

Example of requesting a device reference:
```lua title="ServerScriptService.TestDevice"
local ims = require(script.Parent.IMSServer.Interface)

local device = ims.GetDevice("myDevice")
```

The reference to the device "myDevice" is now stored in the device variable and can be used for further processing. (i.e. getting/setting the state.)

:::important

The `Interface.GetDevice()` function should only be called once per device and the reference should be saved in a variable!

:::

## Manipulating the State

Every device defined in the Neo-IMS system has a State.

Examples for a state would be:
- The currently selected position on a switch
- Whether or not a button is currently depressed
- Whether or not an indicator light is currently lit

A state can be any type which exists as a Value Object. This means all of the following types are valid:
- Boolean
- BrickColor
- CFrame
- Color3
- Int
- Number
- Object
- Ray
- String
- Vector3

---

A state that is only made up of one value is refered to as a **Basic State**.

The Neo-IMS makes manipulating a Basic State very simple.

In this example we will imagine an indicator light stored in a variable named "indicator".
For a simple indicator light the state is a **boolean**.

To **Set** the state of the indicator, you would do the following:

```lua title="ServerScriptService.IndicatorTest"
local indicator = ims.GetDevice("myIndicator")

indicator:SetState(true)
```

To **Get** the state of the indicator, you would do the following:

```lua title="ServerScriptService.IndicatorTest"
local indicator = ims.GetDevice("myIndicator")

local value = indicator:GetState()

-- alternative - both do the same thing
local value = indicator.state
```

It is also possible to **Subscribe** to a state change event:
```lua title="ServerScriptService.IndicatorTest"
local indicator = ims.GetDevice("myIndicator")

indicator.OnStateChanged:Connect(function(state)
    -- your code here
end)
```

---

In addition to **Basic States**, it is also possble to combine multiple values into one state. This is called a **Complex State**

Complex States are a table which contains multiple different **StateKeys** (or alternatively, **Substates**)

As an example for **Setting** a **Complex State**, we will use a traffic light. Traffic lights have three individual lights.
This means the state is made up of **three booleans** named **red**, **yellow**, and **green**.

If we were to use `trafficlight:SetState()` from above, we would need to pass a table containing all three values and the existing state would be replaced. Most of the time, this is not what you want. Instead you can do the following:

Say we want to turn on only the green light, but leave the remaining two lights how they were.
```lua title="ServerScriptService.TrafficLightTest"
local trafficlight = ims.GetDevice("TrafficLight")

indicator:SetStateKey({green = true}) -- This will only affect the green light, yellow and red will stay as they are.
```

If you pass multiple keys into this function, they will also be affected.
```lua title="ServerScriptService.TrafficLightTest"
local trafficlight = ims.GetDevice("TrafficLight")

indicator:SetStateKey({green = true, yellow = true}) -- Yellow and green will turn on, red will stay as it was.
```

To **Get** a complex state, the same functions as the **Basic State** can be used as they will just return a table.

## Recieving Messages

Messages are data sent by the client to request the server to do something. This could for example be the user clicking on a button.

A client message is made up of a table and handling these messages is up to the programmer.

To handle a message, add the following to your device's server module:
```lua title="ServerScriptService.IMSServer.Devices.MyDevice"
function Module.RecieveMessage(self:types.Device<boolean>, player:Player, msg:{[string]:any}):boolean
    -- message handling code
end
```

This function needs to return either true or false depending on whether or not handling the message was successful.

:::warning
Neo-IMS by default does not provide any exploit protection for message handling.

You are required to implement this yourself.
:::