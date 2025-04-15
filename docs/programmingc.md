---
sidebar_position: 3
---

# Client Side Programming

## Device Initialization

Client Side device modules are stored within the `StarterPlayer.StarterPlayerScripts.IMSClient.Devices(.VR)` folder. These modules are automatically loaded by the system as explained in [Introduction](./intro.md#client-side).

The most basic form of a client module looks like this:
```lua title="StarterPlayer.StarterPlayerScripts.IMSClient.Devices.Test"
local module = {}

function module.Init(deviceModel:Model, deviceState:boolean) -- change this type to match your device

end

function module.Update(deviceModel:Model, deviceState:boolean) -- change this type to match your device

end

return module
```

The `Init` function runs **once** when the device gets initialized.

The `Update` function runs every time the state of the device updates on the server.

The `deviceModel` parameter can be used to visually update (animate) the device's model in accordance with the state.

The programmer is responsible for any further handling of logic.

## Manipulating the State

To request a state change to the server, the remote event in `ReplicatedStorage.IMSShared.SendDeviceMessage` can be used.

In this remote event, the device's name (this can be done using `deviceModel.Name`), and the message you wish to pass should be passed.

An example call to this remote event looks like this:
```lua
local repStor = game:GetService("ReplicatedStorage")

function module.Init(deviceModel:Model, deviceState:boolean)
    repStor.IMSShared.SendDeviceMessage:FireServer(deviceModel.Name, {["messageKey"]:"messageValue"})
end
```