--!Type(Client)

local module = require("Module")

function self:Start()
    module.HappyDayResponse:Connect(function(payload: string)
        print("Happy day! Most recent payload: " .. payload)
    end)

    Timer.After(1, function() 
        module.HappyDayRequest:FireServer("Hello from a client! My player's name is " .. self.player.name)
    end)
end