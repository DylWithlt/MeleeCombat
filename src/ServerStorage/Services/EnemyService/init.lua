local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)

local Enemy = require(script.Enemy)

local EnemyService = Knit.CreateService {
    Name = "EnemyService";
    Client = {};
}

local ENEMY_TAG = "Enemy"

function EnemyService:KnitStart()
    
end

function EnemyService:NewEnemy(inst)
    inst.AncestryChanged:Connect(function(parent)
        if inst:IsDescendantOf(workspace) then
            Enemy.new(inst)
        else
            if Enemy.Enemies[inst] then Enemy.Enemies[inst]:Destroy() end
        end
    end)
    
    if not inst:IsDescendantOf(workspace) then return end

    Enemy.new(inst)
end

function EnemyService:KnitInit()
    RunService.Stepped:Connect(function(dt)
        for _, enemy in pairs(Enemy.GetAll()) do
            enemy:Update(dt)
        end
    end)

    CollectionService:GetInstanceAddedSignal(ENEMY_TAG):Connect(function(inst)
        EnemyService:NewEnemy(inst)
    end)

    CollectionService:GetInstanceRemovedSignal(ENEMY_TAG):Connect(function(inst)
        if Enemy.Enemies[inst] then Enemy.Enemies[inst]:Destroy() end
    end)

    for _, model in ipairs(CollectionService:GetTagged(ENEMY_TAG)) do
        EnemyService:NewEnemy(model)
    end
end


return EnemyService
