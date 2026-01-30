--!Type(Module)

--------------------------------
------     NETWORKING     ------
--------------------------------

local getLeaderBoardRequest = Event.new("GetLeaderBoardRequest")
local getLeaderBoardResponse = Event.new("GetLeaderBoardResponse")
local getPlayerRankRequest = Event.new("GetPlayerRankRequest")
local getPlayerRankResponse = Event.new("GetPlayerRankResponse")

--------------------------------
------  TYPE DEFINITIONS  ------
--------------------------------

export type LeaderBoardEntries = { LeaderBoardEntry }

--------------------------------
------     LOCAL STATE    ------
--------------------------------

local pending: EventConnection | nil = nil
local pendingTimer: Timer | nil = nil
local playerPending: EventConnection | nil = nil
local playerPendingTimer: Timer | nil = nil

local lb: Leaderboard = Leaderboard

--------------------------------
------     CONSTANTS      ------
--------------------------------

local TIMEOUT_ERROR_CODE = 666
local TIMEOUT_SECONDS = 5

--------------------------------
------  LOCAL FUNCTIONS   ------
--------------------------------

local function cancelQuery()
    if pending then
        pending:Disconnect()
        pending = nil
    end
    if pendingTimer then
        pendingTimer:Stop()
        pendingTimer = nil
    end
end

local function cancelPlayerQuery()
    if playerPending then
        playerPending:Disconnect()
        playerPending = nil
    end
    if playerPendingTimer then
        playerPendingTimer:Stop()
        playerPendingTimer = nil
    end
end

--------------------------------
------  PUBLIC FUNCTIONS  ------
--------------------------------

function QueryLeaderBoard(
    offset: number,
    limit: number,
    cb: (entries: LeaderBoardEntries | nil, err: number | nil) -> ()
)
    if not cb then
        print("ERROR: No callback provided to QueryLeaderBoard")
        return
    end

    cancelQuery()

    pending = getLeaderBoardResponse:Connect(function(entries, err: number | nil)
        cancelQuery()
        if err ~= 0 then
            cb({}, err)
        else
            cb(entries, 0)
        end
    end)

    pendingTimer = Timer.After(TIMEOUT_SECONDS, function()
        cancelQuery()
        cb(nil, TIMEOUT_ERROR_CODE)
    end)

    getLeaderBoardRequest:FireServer(offset, limit)
end

function QueryPlayerRank(cb: (entry: LeaderBoardEntry | nil, err: number | nil) -> ())
    if not cb then
        print("ERROR: No callback provided to QueryPlayerRank")
        return
    end

    cancelPlayerQuery()

    playerPending = getPlayerRankResponse:Connect(function(entry, err: number | nil)
        cancelPlayerQuery()
        if err ~= 0 then
            cb({}, err)
        else
            cb(entry, 0)
        end
    end)

    playerPendingTimer = Timer.After(TIMEOUT_SECONDS, function()
        cancelPlayerQuery()
        cb(nil, TIMEOUT_ERROR_CODE)
    end)

    getPlayerRankRequest:FireServer()
end

--------------------------------
------  LIFECYCLE HOOKS   ------
--------------------------------

function self:ServerAwake()
    getPlayerRankRequest:Connect(function(player: Player)
        lb.GetEntryForPlayer("my_leaderboard", player, function(entry: LeaderboardEntry, err: LeaderboardError)
            if err ~= 0 then
                print("ERROR: Error retrieving player entry: " .. err)
                getPlayerRankResponse:FireClient(player, nil, err)
                return
            end

            local _entry = {
                id = 0,
                name = "No rank yet",
                score = 0,
                rank = 0,
            }

            if entry then
                _entry = {
                    id = entry.id,
                    name = entry.name,
                    score = entry.score,
                    rank = entry.rank,
                }
            end

            getPlayerRankResponse:FireClient(player, _entry, err)
        end)
    end)

    getLeaderBoardRequest:Connect(function(player: Player, offset: number, limit: number)
        lb.GetEntries("my_leaderboard", offset, limit, function(entries, err)
            if err ~= 0 then
                print("ERROR: Error retrieving leaderboard entries: " .. err)
                getLeaderBoardResponse:FireClient(player, {}, err)
                return
            end

            local _entries = {}
            for _, entry in ipairs(entries) do
                table.insert(_entries, {
                    id = entry.id,
                    name = entry.name,
                    score = entry.score,
                    rank = entry.rank,
                })
            end

            getLeaderBoardResponse:FireClient(player, _entries, err)
        end)
    end)
end
