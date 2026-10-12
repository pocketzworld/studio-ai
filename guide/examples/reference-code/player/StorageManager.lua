--!Type(Module)

--------------------------------
------     NETWORKING     ------
--------------------------------

GetDataRequest = Event.new("GetDataRequest")
GetDataResponse = Event.new("GetDataResponse")
SetDataRequest = Event.new("SetDataRequest")

GetPlayerDataRequest = Event.new("GetPlayerDataRequest")
GetPlayerDataResponse = Event.new("GetPlayerDataResponse")
SetPlayerDataRequest = Event.new("SetPlayerDataRequest")

--------------------------------
------  LIFECYCLE HOOKS   ------
--------------------------------

function self:ClientAwake()
    GetDataResponse:Connect(function(key, value)
        print("Got data from storage: " .. key .. ", " .. tostring(value))
    end)

    GetPlayerDataResponse:Connect(function(key, value)
        print("Got player data from storage: " .. key .. ", " .. tostring(value))
    end)
end

function self:ServerAwake()
    local function validatePlayer(player)
        return player.user.id == server.info.ownerId or player.user.id == server.info.creatorId
    end

    GetDataRequest:Connect(function(player, key)
        Storage.GetValue(key, function(value)
            GetDataResponse:FireClient(player, key, value)
        end)
    end)

    SetDataRequest:Connect(function(player, key, value)
        if not validatePlayer(player) then return end
        Storage.SetValue(key, value)
    end)

    GetPlayerDataRequest:Connect(function(player, key)
        Storage.GetPlayerValue(player, key, function(value)
            GetPlayerDataResponse:FireClient(player, key, value)
        end)
    end)

    SetPlayerDataRequest:Connect(function(player, key, value)
        Storage.SetPlayerValue(player, key, value)
    end)
end
