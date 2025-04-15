local types = require(script.Parent.Parent.IMSServer.Types)
local device = require(script.Parent.Parent.IMSServer.Bases.Device)

local Test = {}
Test.__index = Test
setmetatable(Test, device)

function Test.new(model:Model, initialState:boolean):types.Device<boolean>
	if initialState ~= nil and type(initialState) ~= "boolean" then
		error("[INTERACTION SYSTEM]: InitialState type for Test must be boolean!")
		return nil
	end
	
	local self = device.new(model, initialState or false)
	setmetatable(self, Test)
	
	print("It worked :D")

	return self
end

return Test