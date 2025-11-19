--!Type(Client)

local module = require("Module")

function self:Start()
    module.AnnounceResponse:Connect(function(payload: string)
        print(payload)
    end)

    Timer.After(1, function() 
        module.AnnounceRequest:FireServer("Hello from a client! My player's name is " .. client.localPlayer.name)
    end)
end