--!Type(Module)

AnnounceRequest = Event.new("AnnounceRequest")
AnnounceResponse = Event.new("AnnounceResponse")

function self:ServerStart()
    AnnounceRequest:Connect(function(payload: string)
        AnnounceResponse:FireAllClients(payload)
    end)
end