--!Type(Module)

HappyDayRequest = Event.new("HappyDayRequest")
HappyDayResponse = Event.new("HappyDayResponse")

local lastReceivedPayload: string = nil

local function handlePayload(payload: string)
    lastReceivedPayload = payload
end

function self:ServerStart()
    HappyDayRequest:Connect(function(player: Player, payload: string)
        handlePayload(payload)
        Timer.After(1, function()
            HappyDayResponse:FireClient(player, lastReceivedPayload)
            Timer.After(1, function() 
                HappyDayResponse:FireAllClients(lastReceivedPayload)
            end)
        end)
    end)
end