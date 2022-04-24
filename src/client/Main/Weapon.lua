local Weapon = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

local Client = Player.PlayerScripts.Client.Main
local Keybinds = require(Client.Keybinds)

local Util = require(ReplicatedStorage.Common.Util)

local onEquip = Util.AwaitRemote("Equip")
local onUnequip = Util.AwaitRemote("Unequip")
local onAttack = Util.AwaitRemote("Attack")

Weapon.Equipped = false

function Weapon.Attack(action, state, obj)
    if not (state == Enum.UserInputState.Begin) then return end

    onAttack:FireServer()
end

function Weapon.ToggleEquip(action, state, obj)
    if not (state == Enum.UserInputState.Begin) then return end

    Weapon.Equipped = not Weapon.Equipped

    if Weapon.Equipped then
        Keybinds.BindKey("Attack", Weapon.Attack, false, Enum.UserInputType.MouseButton1)

        onEquip:FireServer()
    else
        Keybinds.Unbind("Attack")

        onUnequip:FireServer()
    end
end

function Weapon.Init()
    Keybinds.BindKey("ToggleEquip", Weapon.ToggleEquip, false, Enum.KeyCode.E)
end

return Weapon
