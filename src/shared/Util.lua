local Util = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

function Util.CreateRemote(name, type)
    local remote = Instance.new(type)
    remote.Name = name
    remote.Parent = Remotes
    return remote
end

function Util.AwaitRemote(name)
    return Remotes:WaitForChild(name, 3)
end

function Util.WeldBetween(a, b)
    local Weld = Instance.new("WeldConstraint")
    Weld.Part0 = a
    Weld.Part1 = b
    Weld.Parent = a
    return Weld
end

function Util.InitializeChildren(parent)
    for _, mod in ipairs(parent:GetChildren()) do
        if not mod:IsA("ModuleScript") then continue end

        local module = require(mod)

        if not module.Init then continue end
        module.Init()
    end
end

return Util