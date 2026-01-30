--!Type(Module)

--------------------------------
------  TYPE DEFINITIONS  ------
--------------------------------

Tween = {}
Tween.__index = Tween

Easing = {
    -- Linear
    linear = function(t) return t end,

    -- Quadratic
    easeInQuad = function(t) return t * t end,
    easeOutQuad = function(t) return t * (2 - t) end,
    easeInOutQuad = function(t)
        if t < 0.5 then return 2 * t * t
        else return -1 + (4 - 2 * t) * t end
    end,

    -- Cubic
    easeInCubic = function(t) return t * t * t end,
    easeOutCubic = function(t)
        t = t - 1
        return t * t * t + 1
    end,
    easeInOutCubic = function(t)
        if t < 0.5 then return 4 * t * t * t
        else
            t = t - 1
            return 4 * t * t * t + 1
        end
    end,

    -- Back (overshoot)
    easeInBack = function(t)
        local _c1 = 1.70158
        local _c3 = _c1 + 1
        return _c3 * t * t * t - _c1 * t * t
    end,
    easeOutBack = function(t)
        local _c1 = 1.70158
        local _c3 = _c1 + 1
        t = 1 - t
        return 1 - (_c3 * t * t * t - _c1 * t * t)
    end,
    easeInBackLinear = function(t)
        local _c1 = 3
        local _c3 = _c1 + 1
        if t < 0.5 then return _c3 * t * t * t - _c1 * t * t
        else
            local _linearT = (t - 0.5) * 2
            return (_c3 * 0.5 * 0.5 * 0.5 - _c1 * 0.5 * 0.5) + _linearT
        end
    end,
    inBack = function(t)
        local _c1 = 1.70158
        return t * t * ((_c1 + 1) * t - _c1)
    end,

    -- Bounce
    bounce = function(t)
        if t < (1 / 2.75) then
            return 7.5625 * t * t
        elseif t < (2 / 2.75) then
            t = t - (1.5 / 2.75)
            return 7.5625 * t * t + 0.75
        elseif t < (2.5 / 2.75) then
            t = t - (2.25 / 2.75)
            return 7.5625 * t * t + 0.9375
        else
            t = t - (2.625 / 2.75)
            return 7.5625 * t * t + 0.984375
        end
    end,

    -- Elastic
    easeInElastic = function(t)
        local _c4 = (2 * math.pi) / 3
        if t == 0 then return 0 end
        if t == 1 then return 1 end
        return -math.pow(2, 10 * t - 10) * math.sin((t * 10 - 10.75) * _c4)
    end,
    easeOutElastic = function(t)
        local _c4 = (2 * math.pi) / 3
        if t == 0 then return 0 end
        if t == 1 then return 1 end
        return math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * _c4) + 1
    end,

    -- Exponential
    easeInExpo = function(t)
        return t == 0 and 0 or math.pow(2, 10 * t - 10)
    end,
    easeOutExpo = function(t)
        return t == 1 and 1 or 1 - math.pow(2, -10 * t)
    end,

    -- Sine
    easeInSine = function(t)
        return 1 - math.cos((t * math.pi) / 2)
    end,
    easeOutSine = function(t)
        return math.sin((t * math.pi) / 2)
    end,
    easeInOutSin = function(t)
        return -(math.cos(math.pi * t) - 1) / 2
    end,
}

--------------------------------
------     LOCAL STATE    ------
--------------------------------

local tweens: {[Tween]: Tween} = {}

--------------------------------
------   CLASS METHODS    ------
--------------------------------

function Tween.new(onUpdate): Tween
    local self = setmetatable({}, Tween)
    self.from = 0
    self.to = 1
    self.duration = 1
    self.easing = Easing.linear
    self.onUpdate = onUpdate
    self.onComplete = nil
    self.elapsed = 0
    self.finished = false
    self.loop = false
    self.pingPong = false
    self.direction = 1
    return self
end

function Tween:FromTo(from: number, to: number): Tween
    self.from = from
    self.to = to
    return self
end

function Tween:OnUpdate(onUpdate): Tween
    self.onUpdate = onUpdate
    return self
end

function Tween:Easing(easing): Tween
    self.easing = easing
    return self
end

function Tween:Duration(duration: number): Tween
    self.duration = duration
    return self
end

function Tween:PingPong(): Tween
    self.pingPong = true
    return self
end

function Tween:Loop(): Tween
    self.loop = true
    return self
end

function Tween:OnComplete(onComplete): Tween
    self.onComplete = onComplete
    return self
end

function Tween:Update(deltaTime: number)
    if self.finished then return end

    self.elapsed = self.elapsed + deltaTime * self.direction
    local _t = self.elapsed / self.duration

    if _t >= 1 then
        _t = 1
        if self.loop then
            if self.pingPong then
                self.direction = -self.direction
                self.elapsed = self.duration
            else
                self.elapsed = 0
            end
        else
            self.finished = true
        end
    elseif _t <= 0 and self.pingPong then
        _t = 0
        if self.loop then
            self.direction = -self.direction
            self.elapsed = 0
        else
            self.finished = true
        end
    end

    local _easedT = self.easing(_t)
    local _currentValue = self.from + (self.to - self.from) * _easedT

    if self.onUpdate then
        self.onUpdate(_currentValue)
    end

    if self.finished and self.onComplete then
        self.onComplete()
    end
end

function Tween:Start()
    self.elapsed = 0
    self.finished = false
    self.direction = 1
    tweens[self] = self
end

function Tween:Stop()
    self.finished = true
    tweens[self] = nil
end

function Tween:IsFinished(): boolean
    return self.finished
end

-- Lowercase aliases for backwards compatibility
Tween.update = Tween.Update
Tween.start = Tween.Start
Tween.stop = Tween.Stop
Tween.isFinished = Tween.IsFinished

--------------------------------
------  LIFECYCLE HOOKS   ------
--------------------------------

function self:ClientUpdate()
    for _, tween in pairs(tweens) do
        if not tween.finished then
            tween:Update(Time.deltaTime)
            if tween:IsFinished() then
                tweens[tween] = nil
            end
        end
    end
end

return {
    Tween = Tween,
    Easing = Easing,
}
