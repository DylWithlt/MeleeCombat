local Players = game:GetService("Players")

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local Promise = require(Knit.Util.Promise)

local TestController = Knit.CreateController { Name = "TestController" }

local Player = Players.LocalPlayer

function TestController:KnitStart()
    local DataService = Knit.GetService("DataService")

    print("Testing")
    
    -- DataService.ProfileData.Changed:Connect(function(_data)
    --     print(_data)
    -- end)

    -- local data = DataService.ProfileData:Get() or DataService.ProfileData.Changed:Wait()
    
    Promise.any{
        Promise.try(function()
            return DataService.ProfileData.Changed:Wait()
        end),
        Promise.new(function() return DataService.ProfileData:Get() end)
    }:andThen(function(data)
        print(data)
    end):catch(warn)

    --print(data)
    
end


function TestController:KnitInit()
    print("Test Controller Initialized")
end


return TestController
