local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local User = {}
User.__index = User

local Util = require(ReplicatedStorage.Common.Util)
-- local updateUserRemote = Util.CreateRemote("UpdateUser", "RemoteEvent")
-- local userDataChangedRemote = Util.CreateRemote("userDataChanged", "RemoteEvent")

local UserCache = {}

local CharAddedFuncs = {}

local PLAYER_TAG = "Player"

function User.BindCharAdded(func)
    table.insert(CharAddedFuncs, func)
end

function User.Init()
	Players.PlayerAdded:Connect(function(Player)
		local id = tostring(Player.UserId)
		local _user = User.new(Player)
		UserCache[id] = _user
		UserCache[id]:LoadData()

        Player.CharacterAdded:Connect(function(char)
            char.Archivable = true
            CollectionService:AddTag(char, PLAYER_TAG)

            for _, func in ipairs(CharAddedFuncs) do
                func(char)
            end
        end)
    end)
    Players.PlayerRemoving:Connect(function(Player)
        local id = tostring(Player.UserId)
		local _user = UserCache[id]
		_user:SaveData()
        table.remove(UserCache, id)
    end)
end

function User.GetUser(userId)
	return UserCache[tostring(userId)]
end

function User.new(Player)
    local self = setmetatable({}, User)
    self.Player = Player
    self.Data = {}
    self.Keybinds = {} -- {actionname = "Action", keys = {Enum.KeyCode.A}}

    -- updateUserRemote:FireClient(self.Player, self.Keybinds)

    return self
end

function User.SetData(player, change)
	if not change then return end
	local plyr = User.GetUser(player.UserId)
    for key,value in pairs(change) do
		if not plyr.Data[key] then continue end
		plyr.Data[key] = value
    end
	-- userDataChangedRemote:FireClient(plyr.Player, plyr.Data)
end

function User:LoadData()
	local storeTag = "Player_".. self.Player.UserId

	local dataStore = DataStoreService:GetDataStore("PlayerStats", storeTag)
    local storedData = dataStore:GetAsync(storeTag)

    if not storedData then return end

    local LoadedData = storedData -- insert datastore here
    self.SetData(self.Player,LoadedData)
end

function User:SaveData()
    local storeTag = "Player_".. self.Player.UserId
	local dataStore = DataStoreService:GetDataStore("PlayerStats", storeTag)

    local s, e = pcall(function()
		dataStore:SetAsync(storeTag, self.Data)
	end)
	if not s then print(e) end
end

return User