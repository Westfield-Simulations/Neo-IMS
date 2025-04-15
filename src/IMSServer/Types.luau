--- @class Types
--- @server
--- Basic types used by Neo-IMS.

local repStor = game:GetService("ReplicatedStorage")

local signal = require(repStor.Signal)

--- @interface Device<T>
--- @within Types
--- .name string
--- .model Model
--- .className string
--- .state T
--- .GetState (self:Types.Device<T>) -> T
--- .SetState (self:Types.Device<T>, state:T) -> boolean
--- .SetStateKey (self:Types.Device<T>, stateKey:{[string]:any}) -> boolean
--- .RevieveMessage (self:Types.Device<T>, player:Player, msg:{[string]:any}) -> boolean
--- .OnStateChanged signal
--- .OnStateKeyChanged signal
--- .OnMessageRecieved signal
export type Device<T> = {
    name:string,
    model:Model,
    className:string,
    state:T,

    GetState:(self:Device<T>) -> T,
    SetState:(self:Device<T>, state:T) -> boolean,

    SetStateKey:(self:Device<T>, stateKey:{[string]:any}) -> boolean,

    RecieveMessage:(self:Device<T>, player:Player, msg:{[string]:any}) -> boolean,

    OnStateChanged:signal,
    OnStateKeyChanged:signal,
    OnMessageRecieved:signal
}

return {}