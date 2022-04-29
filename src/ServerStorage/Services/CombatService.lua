local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local CombatService = Knit.CreateService {
    Name = "CombatService";
    Client = {};
}

local Assets = ReplicatedStorage.Assets
local Models = Assets.Models

local Shusui = Models.Shusui
local Sheathe = Models.sheathe

local function weldBetween(a, b)
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = a
    weld.Part1 = b
    weld.Parent = a
    return weld
end

function CombatService.Client:Equip(player)
    local char = player.Character
    if not char then return end

    local lastSword = char:FindFirstChild(Shusui.Name)
    if lastSword then lastSword:Destroy() end

    local rightHand = char:FindFirstChild("RightHand")
    if not rightHand then return end

    local sword = Shusui:Clone()
    for _, part in ipairs(sword:GetChildren()) do
        if not part:IsA("BasePart") or part == sword.PrimaryPart then continue end

        weldBetween(sword.PrimaryPart, part)
    end
    
    sword:SetPrimaryPartCFrame(rightHand.CFrame * CFrame.Angles(0,math.rad(90),0))
    weldBetween(sword.PrimaryPart, rightHand)

    sword.Parent = char
end

function CombatService.Client:Unequip(player)
    local char = player.Character
    if not char then return end
    
    local lastSword = char:FindFirstChild(Shusui.Name)
    if lastSword then lastSword:Destroy() end
end

function CombatService:InitializeChar(char)
    local lowerTorso = char:FindFirstChild("LowerTorso")
    if not lowerTorso then return end

    local _sheathe = Sheathe:Clone()
    _sheathe:SetPrimaryPartCFrame(lowerTorso.CFrame
        * CFrame.new(-(lowerTorso.Size.X/2 + _sheathe.PrimaryPart.Size.Z/2), 0, 0)
        * CFrame.Angles(0, math.rad(90), 0))

    local motor6d = Instance.new("Motor6D")
    motor6d.Part0 = lowerTorso
    motor6d.Part1 = _sheathe.PrimaryPart
    motor6d.C0 = lowerTorso.CFrame:inverse() * _sheathe.PrimaryPart.CFrame
    motor6d.Parent = lowerTorso

    _sheathe.Parent = char
end

function CombatService:KnitInit()
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(char)
            CombatService:InitializeChar(char)
        end)
    end)
end


return CombatService
