local repStor = game:GetService("ReplicatedStorage")

local signal = require(repStor.Signal)

export type Device<T> = {
    name:string,
    model:Model,
    className:string,
    state:T,

    GetState:(self:Device<T>) -> T,
    SetState:(self:Device<T>, state:T) -> boolean,

    SetStateKey:(self:Device<T>, stateKey:{[string]:any}) -> boolean, --! Deprecated: Use SetSubstate instead

    RecieveMessage:(self:Device<T>, player:Player, msg:{[string]:any}) -> boolean,

    OnStateChanged:signal,
    OnStateKeyChanged:signal,
    OnMessageRecieved:signal
}

return {}