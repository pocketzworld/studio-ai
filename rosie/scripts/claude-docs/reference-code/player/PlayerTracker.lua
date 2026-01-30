--!Type(Module)

--------------------------------
------  TYPE DEFINITIONS  ------
--------------------------------

export type PlayerInfo = {
    UserId: string,
    Player: Player,
    Model: CharacterModel,
}

--------------------------------
------     NETWORKING     ------
--------------------------------

PlayerJoinedEvent = Event.new("PlayerJoinedEvent")
PlayerLeftEvent = Event.new("PlayerLeftEvent")

--------------------------------
------     LOCAL STATE    ------
--------------------------------

local playerDataList: { [string]: PlayerInfo } = {}

--------------------------------
------  LOCAL FUNCTIONS   ------
--------------------------------

local function validatePlayer(player: Player): boolean
    local _success = pcall(function()
        local _ = player.name
    end)
    return _success
end

local function validateAndRemovePlayers()
    local _playersToRemove = {}
    for playerId, playerInfo in pairs(playerDataList) do
        if not validatePlayer(playerInfo.Player) then
            table.insert(_playersToRemove, playerId)
        end
    end
    for _, playerId in ipairs(_playersToRemove) do
        playerDataList[playerId] = nil
        print("Removed invalid player: " .. playerId)
    end
end

local function createPlayerData(playerId: string, player: Player): PlayerInfo
    return {
        UserId = playerId,
        Player = player,
        Model = nil,
    }
end

local function trackPlayers(game, characterCallback)
    server.PlayerConnected:Connect(function(player)
        print("[PlayerTracker] Player " .. player.name .. " has joined the game.")
        playerDataList[player.user.id] = createPlayerData(player.user.id, player)

        PlayerJoinedEvent:Fire(player)

        player.CharacterChanged:Connect(function(player, character)
            local _playerinfo = GetPlayerDataById(player.user.id)
            if character == nil then return end

            if characterCallback then
                characterCallback(_playerinfo)
            end
        end)
    end)

    server.PlayerDisconnected:Connect(function(player)
        if validatePlayer(player) then
            print("[PlayerTracker] Player " .. player.user.id .. " has left the game.")
            playerDataList[player.user.id] = nil
        end
        PlayerLeftEvent:Fire(player)
    end)
end

local function clientTrackPlayers()
    if not client then return end

    scene.PlayerJoined:Connect(function(scene, player)
        print("[PlayerTracker] Player " .. player.name .. " has joined the scene.")
        playerDataList[player.user.id] = createPlayerData(player.user.id, player)
    end)

    scene.PlayerLeft:Connect(function(scene, player)
        print("[PlayerTracker] Player " .. player.name .. " has left the scene.")
        playerDataList[player.user.id] = nil
    end)
end

--------------------------------
------  PUBLIC FUNCTIONS  ------
--------------------------------

function RemovePlayer(playerId: string, playerData: PlayerInfo)
    if not playerId then
        print("ERROR: No player ID provided to RemovePlayer")
        return
    end
    playerDataList[playerId] = nil
end

function GetPlayerDataById(playerId: string): PlayerInfo
    if not playerId then
        print("ERROR: No player ID provided to GetPlayerDataById")
        return nil
    end

    for id: string, playerInfo in pairs(playerDataList) do
        if id == playerId then
            return playerInfo
        end
    end
    if client then
        local _newPlayerData = createPlayerData(playerId, nil)
        playerDataList[playerId] = _newPlayerData
        return _newPlayerData
    end
    return nil
end

function GetPlayerById(playerId: string): Player | nil
    if not playerId then
        print("ERROR: No player ID provided to GetPlayerById")
        return nil
    end

    local _playerInfo = GetPlayerDataById(playerId)
    if _playerInfo then
        return _playerInfo.Player
    end
    return nil
end

function GetLocalPlayerData(): PlayerInfo
    return playerDataList[client.localPlayer.user.id]
end

function GetPlayerCount(): number
    local _count = 0
    for _ in pairs(playerDataList) do
        _count = _count + 1
    end
    return _count
end

function GetPlayerInfo(player: Player): PlayerInfo | nil
    if not player then
        print("ERROR: No player provided to GetPlayerInfo")
        return nil
    end

    if not server then
        print("ERROR: GetPlayerInfo called on client")
        return nil
    end
    if not validatePlayer(player) then
        return nil
    end
    return playerDataList[player.user.id]
end

function GetPlayers(): { [string]: PlayerInfo }
    validateAndRemovePlayers()
    return playerDataList
end

function RegisterCharacterModel(playerId: string, model: CharacterModel)
    if not client then return end
    if not playerId then
        print("ERROR: No player ID provided to RegisterCharacterModel")
        return
    end

    local _info = playerDataList[playerId]
    if not _info then return end
    _info.Model = model
end

function GetCharacterModelForPlayerId(id: string): CharacterModel
    if not id or id == "" then return nil end
    local _playerInfo = GetPlayerDataById(id)
    if _playerInfo then
        return _playerInfo.Model
    end
    return nil
end

--------------------------------
------  LIFECYCLE HOOKS   ------
--------------------------------

function self:ClientAwake()
    playerDataList[client.localPlayer.user.id] = createPlayerData(
        client.localPlayer.user.id,
        client.localPlayer
    )
    clientTrackPlayers()
end

function self:ServerAwake()
    trackPlayers(server)
end
