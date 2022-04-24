local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)
local Signal = require(Packages.Signal)
local ProfileService = require(Packages.ProfileService)

local DataService = Knit.CreateService {
    Name = "DataService";
    Profiles = {},
    StatsChanged = Signal.new(),
    Client = {
        DataChanged = Knit.CreateSignal(),
        ProfileData = Knit.CreateProperty()
    };
}

local ProfileTemplate = {
    Cash = 0,
    Gems = 0,
    LastLoginTime = 0
}

local ProfileStore = ProfileService.GetProfileStore("PlayerData", ProfileTemplate)

local PLAYER_TAG = "Player"

function DataService:KnitStart()
    
end

function DataService:OnLoad(player, profile)
    profile.Data.LastLoginTime = workspace:GetServerTimeNow()
    self.Client.ProfileData:SetFor(player, profile.Data)

    print("Loaded Player:", player)
end

function DataService:PlayerAdded(player)
    local profile = ProfileStore:LoadProfileAsync("Player_"..player.UserId)
    if not profile then player:Kick() return end

    profile:AddUserId(player.UserId)
    profile:Reconcile()
    profile:ListenToRelease(function()
        self.Profiles[player] = nil
        player:Kick()
    end)

    if not player:IsDescendantOf(Players) then profile:Release() return end

	self.Profiles[player] = profile
	self:OnLoad(player, profile)
end

function DataService:KnitInit()
    for _, player in ipairs(Players:GetPlayers()) do
        DataService:PlayerAdded(player)
    end

	Players.PlayerAdded:Connect(function(player)
		DataService:PlayerAdded(player)

        player.CharacterAdded:Connect(function(char)
            CollectionService:AddTag(char, PLAYER_TAG)
        end)
	end)
	Players.PlayerRemoving:Connect(function(player)
		local profile = self.Profiles[player]
        if not profile then return end

        profile:Release()
	end)
end


return DataService
