--!Type(Module)

AnnounceRequest = Event.new("AnnounceRequest")
AnnounceResponse = Event.new("AnnounceResponse")

local lastReceivedPayload: string = nil

function self:ServerStart()
    AnnounceRequest:Connect(function(player: Player, payload: string)
        lastReceivedPayload = payload
        Timer.After(2, function()
            AnnounceResponse:FireClient(player, lastReceivedPayload)
        end)
    end)
end