--!Type(Module)

--------------------------------
------  TYPE DEFINITIONS  ------
--------------------------------

Tween = {}
Tween.__index = Tween

Easing = {
    linear = function(t) return t end,

    easeInQuad = function(t) return t * t end,
    easeOutQuad = function(t) return t * (2 - t) end,
    easeInOutQuad = function(t)
        if t < 0.5 then
            return 2 * t * t
        else
            return -1 + (4 - 2 * t) * t
        end
    end,

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
        if t < 0.5 then
            return _c3 * t * t * t - _c1 * t * t
        else
            local _linearT = (t - 0.5) * 2
            return (_c3 * 0.5 * 0.5 * 0.5 - _c1 * 0.5 * 0.5) + _linearT
        end
    end,

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
    end
}

--------------------------------
------     LOCAL STATE    ------
--------------------------------

local tweens: {[Tween]: Tween} = {}

--------------------------------
------   CLASS METHODS    ------
--------------------------------

function Tween.new(from: number, to: number, duration: number, loop: boolean, pingPong: boolean, easing, onUpdate, onComplete): Tween
    local self = setmetatable({}, Tween)
    self.from = from
    self.to = to
    self.duration = duration
    self.loop = loop
    self.pingPong = pingPong
    self.easing = easing or Easing.linear
    self.onUpdate = onUpdate
    self.onComplete = onComplete
    self.elapsed = 0
    self.finished = false
    self.direction = 1
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
        self.onUpdate(_currentValue, _easedT)
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

function Tween:Stop(doCompleteCB: boolean)
    doCompleteCB = doCompleteCB or false
    self.finished = true
    if doCompleteCB and self.onComplete then
        self.onComplete()
    end
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
    Easing = Easing
}
