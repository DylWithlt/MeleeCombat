local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Util = require(ReplicatedStorage.Common.Util)

return function()
    Util.InitializeChildren(script)
end