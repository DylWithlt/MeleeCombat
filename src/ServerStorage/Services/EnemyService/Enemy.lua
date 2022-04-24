local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Enemy = {}
Enemy.__index = Enemy
Enemy.Tag = "Enemy"

local MASK2D = Vector3.new(1, 0, 1)
local VIEWDIST = 20
local FOV = math.rad(150/2)

local PLAYER_TAG = "Player"
local ENEMY_TAG = "Enemy"

local MIN_DIST = 20

local Animations = ReplicatedStorage.Assets.Animations

Enemy.Enemies = {}

function Enemy.GetAll()
    return Enemy.Enemies
end

local States = {
    Chasing = {
        Anim = "Running",
    },
    Idle = {
        Anim = "Idle",
    },
    Retreat = {
        Anim = "Move Back"
    }
}

function Enemy.new(model)
    local self = setmetatable({}, Enemy)

    self.Model = model
    self.lastTarget = nil
    self.State = "Idle"
    self.CurrAnim = "Idle"
    self.LastState = self.State
    self.Speed = 0

    self.EnemyType = self.Model:GetAttribute("EnemyType") or "Default"
    if not Animations[self.EnemyType] then self.EnemyType = "Default" end
    
    for _, part in ipairs(self.Model:GetDescendants()) do
		if not part:IsA("BasePart") then continue end

        part:SetNetworkOwner(nil)
	end

    self:PreloadAnims()
    self:Animate()

    Enemy.Enemies[self.Model] = self

    return self
end

function Enemy:Destroy()
    Enemy.Enemies[self.Model] = nil
    setmetatable(self, nil)
end

function Enemy:Update(dt)
    if not self.Model:IsDescendantOf(workspace) then return end

    self.Target = self:GetTarget()
    self:Move()
    self:GetState()
end

function Enemy:PreloadAnims()
    self.AnimsFolder = Animations[self.EnemyType]

    local hum = self.Model:FindFirstChildWhichIsA("Humanoid")
    local animator = hum:FindFirstChildWhichIsA("Animator")
    if not animator then warn("No animator found in humanoid.") return end

    local _animations = {}
    for _, anim in ipairs(self.AnimsFolder:GetChildren()) do
        _animations[anim.Name] = animator:LoadAnimation(anim)
    end

    self.Animations = _animations

    hum.Running:Connect(function(speed)
        self.Speed = speed
    end)
end

function Enemy:GetState()

    

    if self.Speed > 0 then

        local humroot = self.Model.PrimaryPart
        local target = self.Target and self.Target.PrimaryPart
        if not (humroot and target) then return end

        local dir = (target.CFrame.Position - humroot.CFrame.Position)

        local movingBack = dir.Magnitude < MIN_DIST

        if movingBack then
            self:SetState("Retreat")
        else
            self:SetState("Chasing")
        end
    else
        self:SetState("Idle")
    end

    if self.State ~= self.LastState then
        self.LastState = self.State
        self:Animate()
    end
end

function Enemy:SetState(stateName)
    local state = States[stateName]
    if not state then return end

    self.State = stateName
    self.CurrAnim = state.Anim
    
    if self.State ~= self.LastState then
        self.LastState = self.State
        self:Animate()
    end
end

function Enemy:Animate()
    local newAnim = self.Animations[self.CurrAnim]

    for _, track in pairs(self.Animations) do
        track:Stop()
    end

    if newAnim then
        newAnim:Play()
    end
end

function Enemy:Move()
    if not self.Target then return end -- Might want to not do this in order to move if theres no targets.

    local humroot = self.Model.PrimaryPart
    local dir = (self.Target.PrimaryPart.CFrame.Position - humroot.CFrame.Position)


    local NewPos = dir.Unit * (dir.Magnitude < MIN_DIST and (dir.Magnitude - MIN_DIST) or math.min(dir.Magnitude - MIN_DIST, MIN_DIST))

    self.Model.Humanoid:MoveTo(humroot.CFrame.Position + NewPos)
    humroot.AlignOrientation.PrimaryAxis = CFrame.lookAt(humroot.CFrame.Position * MASK2D, self.Target.PrimaryPart.CFrame.Position * MASK2D).Rotation.RightVector
end

function Enemy:GetAllies()
    local head = self.Model:FindFirstChild("Head")
    if not head then warn("No Head found when searching for target.") return end

    local overlap = OverlapParams.new()
    overlap.FilterDescendantsInstances = CollectionService:GetTagged(ENEMY_TAG)
    overlap.FilterType = Enum.RaycastFilterType.Whitelist

    local sqr = workspace:GetPartBoundsInRadius(head.CFrame.Position, VIEWDIST, overlap)
    if not sqr then return end



end

function Enemy:GetTarget()
    local head = self.Model:FindFirstChild("Head")
    if not head then warn("No Head found when searching for target.") return end
    -- Check if anyone is around enemy.
    local overlap = OverlapParams.new()
    overlap.FilterDescendantsInstances = CollectionService:GetTagged(PLAYER_TAG)
    overlap.FilterType = Enum.RaycastFilterType.Whitelist

    local sqr = workspace:GetPartBoundsInRadius(head.CFrame.Position, VIEWDIST, overlap)
    if not sqr then return end

    local foundEnemies = {}
    -- filter enemies
    for _, part in ipairs(sqr) do
        -- TODO: Check if part can be seen with a ray. Check if part is within spherical sector.
        local dirRay = (part.CFrame.Position - head.CFrame.Position)

        local angle = math.acos(head.CFrame.LookVector:Dot(dirRay.Unit))
        if angle > FOV then continue end

        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {self.Model}
        params.FilterType = Enum.RaycastFilterType.Blacklist

        local rcr = workspace:Raycast(head.CFrame.Position, dirRay, params)
        if not rcr then continue end

        -- Check if model already saved.
        local model = part:FindFirstAncestorWhichIsA("Model")
        if not model then continue end

        if table.find(foundEnemies, model) then continue end

        table.insert(foundEnemies, model)
    end

    if #foundEnemies <= 0 then return end

    -- Return last target if it's still within range.
    local lastTarget = self._LastTarget
    if lastTarget and table.find(foundEnemies, lastTarget) then
        return lastTarget
    end

    -- If there is no last target or it's not in range anymore.
    -- Find the closest of the foundEnemies.

    local closestAngle = 360
    local closestModel = nil
    for _, model in ipairs(foundEnemies) do
        local dirRay = (model.PrimaryPart.CFrame.Position - head.CFrame.Position)

        local angle = math.acos(head.CFrame.LookVector:Dot(dirRay.Unit))
        if angle > closestAngle then continue end

        closestAngle = angle
        closestModel = model
    end

    return closestModel
end

return Enemy