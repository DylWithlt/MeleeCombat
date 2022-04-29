local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local Packages = ReplicatedStorage.Packages

local Keyboard = require(Packages.Input).Keyboard.new()

local CombatController = Knit.CreateController({ Name = "CombatController" })

local Player = Players.LocalPlayer

local lastSwordAction = 0
local isEquipped = false

function CombatController:ToggleEquip()
	print((os.time() - lastSwordAction))
	if (os.time() - lastSwordAction) < 1 then
		return
	end
	lastSwordAction = os.time()

	local CombatService = Knit.GetService("CombatService")

	if not isEquipped then
		CombatService:Equip()
		isEquipped = true
	else
		CombatService:Unequip()
        isEquipped = false
	end
end

function CombatController:KnitStart()
	Keyboard.KeyDown:Connect(function(key: KeyCode)
		if key == Enum.KeyCode.E then
			CombatController:ToggleEquip()
		end
	end)
end

function CombatController:KnitInit() end

return CombatController
