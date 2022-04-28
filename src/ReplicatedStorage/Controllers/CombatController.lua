local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local Packages = ReplicatedStorage.Packages

local Keyboard = require(Packages.Input).Keyboard.new()

local CombatController = Knit.CreateController { Name = "CombatController" }


function CombatController:KnitStart()
    local CombatService = Knit.GetService("CombatService")

    Keyboard.KeyDown:Connect(function(key: KeyCode)
        if key == Enum.KeyCode.E then
            CombatService:ToggleEquip()
        end
    end)
end


function CombatController:KnitInit()
    
end


return CombatController
