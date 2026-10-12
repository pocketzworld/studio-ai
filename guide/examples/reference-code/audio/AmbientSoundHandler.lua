--!Type(Client)

--------------------------------
------  SERIALIZED FIELDS ------
--------------------------------

--!SerializeField
local thunderSound: AudioShader = nil
--!SerializeField
local thunderTimeRange: Vector2 = nil

--!SerializeField
local birdSound: AudioShader = nil
--!SerializeField
local birdTimeRange: Vector2 = nil

--!SerializeField
local windSound: AudioShader = nil
--!SerializeField
local windTimeRange: Vector2 = nil

--------------------------------
------  LOCAL FUNCTIONS   ------
--------------------------------

local function playSound(sound: AudioShader)
    if sound then
        Audio:PlaySoundGlobal(sound, 1, 1, false)
    end
end

local function playSoundAfterDelay(sound: AudioShader, timeRange: Vector2)
    if not sound or not timeRange then return end

    local _time = math.random(timeRange.x, timeRange.y)
    Timer.After(_time, function()
        playSound(sound)
        playSoundAfterDelay(sound, timeRange)
    end)
end

--------------------------------
------  LIFECYCLE HOOKS   ------
--------------------------------

function self.ClientAwake()
    playSoundAfterDelay(thunderSound, thunderTimeRange)
    playSoundAfterDelay(birdSound, birdTimeRange)
    playSoundAfterDelay(windSound, windTimeRange)
end
