local Client = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Util = require(ReplicatedStorage.Common.Util)

local Player = Players.LocalPlayer

local CharacterAddedFunctions = {}
function Client.BindCharAdded(func)
    table.insert(CharacterAddedFunctions, func)
end

function Client.InitCharAdded()
    Player.CharacterAdded:Connect(function(char)
        for _, func in ipairs(CharacterAddedFunctions) do
            func(char)
        end
    end)
end

function Client.Init()
    Client.InitCharAdded()

    Util.InitializeChildren(script)
end

return Client