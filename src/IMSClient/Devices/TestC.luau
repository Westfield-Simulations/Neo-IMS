local module = {}

function module.Init(deviceModel:Model, deviceState:boolean)
    print("It worked :3")
    print(deviceModel.Name)
end

function module.Update(deviceModel:Model, deviceState:boolean)
    
end

return module