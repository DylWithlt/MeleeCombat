local Combat = {}

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Util = require(ReplicatedStorage.Common.Util)

local Sword = ReplicatedStorage.Assets.Shusui

local ENEMY_TAG = "Enemy"

function Combat.OnAttack(player)
    local char = player.Character
    if not char then return end

    local root = char.PrimaryPart
    if not root then return end

    local overlap = OverlapParams.new()
    overlap.FilterDescendantsInstances = CollectionService:GetTagged(ENEMY_TAG)
    overlap.FilterType = Enum.RaycastFilterType.Whitelist
    
    local sqr = workspace:GetPartBoundsInBox(root.CFrame * CFrame.new(0,0,-5), Vector3.new(5, 5, 5), overlap)
    if not sqr then return end

    local foundEnemies = {}
    -- filter enemies
    for _, part in ipairs(sqr) do
        local model = part:FindFirstAncestorWhichIsA("Model")
        if not model then continue end

        if table.find(foundEnemies, model) then continue end

        table.insert(foundEnemies, model)
    end

    -- do damage
    for _, enemy in ipairs(foundEnemies) do
        local hum = enemy:FindFirstChildWhichIsA("Humanoid")
        if not hum then continue end

        hum:TakeDamage(10);
    end

    print("Attack server.")
end

function Combat.OnEquip(player)
    local char = player.Character
    if not char then return end

    local lastSword = char:FindFirstChild(Sword.Name)
    if lastSword then lastSword:Destroy() end

    local _sword = Sword:Clone()
    _sword:PivotTo(char.RightHand.CFrame * CFrame.Angles(0, math.rad(90), 0))
    Util.WeldBetween(_sword.PrimaryPart, char.RightHand)
    _sword.Parent = char
end

function Combat.OnUnequip(player)
    local char = player.Character
    if not char then return end

    local lastSword = char:FindFirstChild(Sword.Name)
    if lastSword then lastSword:Destroy() end
end

function Combat.Init()
    local onEquip = Util.CreateRemote("Equip", "RemoteEvent")
    local onAttack = Util.CreateRemote("Attack", "RemoteEvent")
    local onUnequip = Util.CreateRemote("Unequip", "RemoteEvent")

    onEquip.OnServerEvent:Connect(Combat.OnEquip)
    onAttack.OnServerEvent:Connect(Combat.OnAttack)
    onUnequip.OnServerEvent:Connect(Combat.OnUnequip)
end

return Combat