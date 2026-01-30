--!Type(Module)

--------------------------------
------  SERIALIZED FIELDS ------
--------------------------------

--!SerializeField
local startingPlaylist: MusicPlaylistTemplate = nil
--!SerializeField
local additionalPlaylists: { MusicPlaylistTemplate } = nil

--------------------------------
------     NETWORKING     ------
--------------------------------

-- Networked value exposed globally for syncing current song across clients
CurrentSongInfoValue = TableValue.new("CurrentSongInfo", { playlistName = "Lobby", songID = 1 })

--------------------------------
------     LOCAL STATE    ------
--------------------------------

local volume: number = 1
local playlists: { [string]: MusicPlaylistTemplate } = nil
local enabled: boolean = true
local randomSongOrderList: { number } = nil
local serverSongIndex: number = 1
local songDuration: number = 0
local changeSongTimer: number = 0
local songIsPlaying: boolean = false

--------------------------------
------  LOCAL FUNCTIONS   ------
--------------------------------

local function getCurrentPlaylist(): MusicPlaylistTemplate | nil
    local _playlistName = CurrentSongInfoValue.value.playlistName
    if not playlists[_playlistName] then
        print("ERROR: Invalid playlist name: " .. tostring(_playlistName))
        return nil
    end
    return playlists[_playlistName]
end

local function getCurrentSong()
    local _info = CurrentSongInfoValue.value
    local _trackData = playlists[_info.playlistName].tracklist[_info.songID]
    if not _trackData then
        print("ERROR: Invalid song ID: " .. tostring(_info.songID))
        return nil
    end
    return _trackData
end

local function initializePlaylists()
    playlists = {}
    playlists[startingPlaylist.id] = startingPlaylist
    for _, playlist in ipairs(additionalPlaylists) do
        playlists[playlist.id] = playlist
    end
end

local function randomizeSongOrder(trackCount: number): { number }
    randomSongOrderList = {}
    for i = 1, trackCount do
        table.insert(randomSongOrderList, i)
    end
    local _n = #randomSongOrderList
    for i = _n, 2, -1 do
        local _j = math.random(i)
        randomSongOrderList[i], randomSongOrderList[_j] = randomSongOrderList[_j], randomSongOrderList[i]
    end
    return randomSongOrderList
end

--------------------------------
------  PUBLIC FUNCTIONS  ------
--------------------------------

function InitServer()
    initializePlaylists()
    math.randomseed(os.time())
    SetPlaylist(startingPlaylist)
end

function PlaySong(songInfo)
    if not songInfo then
        print("ERROR: No song info provided to PlaySong")
        return
    end

    changeSongTimer = 0
    local _oldPlaylist = CurrentSongInfoValue.value.playlistName
    local _oldSongID = CurrentSongInfoValue.value.songID

    if songIsPlaying and songInfo.playlistName == _oldPlaylist and songInfo.songID == _oldSongID then
        return
    end

    local _newPlaylist = playlists[songInfo.playlistName]
    songDuration = _newPlaylist.trackDurations[songInfo.songID]
    CurrentSongInfoValue.value = { playlistName = songInfo.playlistName, songID = songInfo.songID }

    if songInfo.playlistName ~= _oldPlaylist or not randomSongOrderList then
        serverSongIndex = 1
        if _newPlaylist.shuffle then
            if songInfo.playlistName ~= _oldPlaylist or not randomSongOrderList then
                randomizeSongOrder(#_newPlaylist.tracklist)
            end
            for i = 1, #randomSongOrderList do
                if randomSongOrderList[i] == songInfo.songID then
                    serverSongIndex = i
                    break
                end
            end
        end
    end

    songIsPlaying = true
end

function AdvanceSong()
    local _currentPlaylist = getCurrentPlaylist()
    if not _currentPlaylist then return end
    if not _currentPlaylist.autoplay then return end

    if serverSongIndex >= #_currentPlaylist.tracklist then
        serverSongIndex = 1
    else
        serverSongIndex = serverSongIndex + 1
    end

    local _nextSongID = (_currentPlaylist.shuffle and randomSongOrderList and randomSongOrderList[serverSongIndex])
        or serverSongIndex
    PlaySong({ playlistName = CurrentSongInfoValue.value.playlistName, songID = _nextSongID })
end

function SetPlaylist(template: MusicPlaylistTemplate, forceFirstTrack: boolean?)
    if not template then
        print("ERROR: No template provided to SetPlaylist")
        return
    end
    serverSongIndex = 1
    local _trueSongID = forceFirstTrack and 1 or math.random(1, #template.tracklist)
    PlaySong({ playlistName = template.id, songID = _trueSongID })
end

function SetPlaylistByName(name: string, forceFirstTrack: boolean?)
    if not name or name == "" then
        print("ERROR: No name provided to SetPlaylistByName")
        return
    end
    if not playlists[name] then
        print("ERROR: Invalid playlist name: " .. tostring(name))
        return
    end
    SetPlaylist(playlists[name], forceFirstTrack)
end

function SetDefaultPlaylist()
    SetPlaylist(startingPlaylist, true)
end

function PlayCurrentSong()
    if not enabled then return end
    Audio:StopMusic(true)
    Timer.After(1, function()
        Audio:PlayMusic(getCurrentSong(), volume, false, false)
    end)
end

function SetEnabled(isEnabled: boolean)
    if enabled == isEnabled then return end
    enabled = isEnabled

    if not isEnabled then
        Audio:StopMusic(false)
    else
        PlayCurrentSong()
    end
end

--------------------------------
------  LIFECYCLE HOOKS   ------
--------------------------------

function self:ServerAwake()
    InitServer()
end

function self.ServerUpdate()
    if not enabled then return end

    if songIsPlaying and songDuration ~= 0 then
        changeSongTimer = changeSongTimer + Time.deltaTime
        if changeSongTimer >= songDuration + 1 and getCurrentPlaylist().autoplay then
            songIsPlaying = false
            AdvanceSong()
        end
    end
end

function self.ClientAwake()
    initializePlaylists()

    CurrentSongInfoValue.Changed:Connect(function()
        PlayCurrentSong()
    end)
    PlayCurrentSong()
end
