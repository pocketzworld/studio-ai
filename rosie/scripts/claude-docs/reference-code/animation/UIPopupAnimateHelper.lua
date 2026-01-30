--!Type(Module)

--------------------------------
------  REQUIRED MODULES  ------
--------------------------------

local TweenModule = require("Tweener")
local Tween = TweenModule.Tween
local Easing = TweenModule.Easing

--------------------------------
------  SERIALIZED FIELDS ------
--------------------------------

--!SerializeField
local openCloseDuration: number = 0.5

--------------------------------
------  LOCAL FUNCTIONS   ------
--------------------------------

local function playSlideUpWithHeight(root: VisualElement, onComplete: () -> () | nil, savedTop: number, height: number)
    root.style.top = StyleLength.new(height)

    local _myTween = Tween:new(function(value)
        root.style.top = StyleLength.new(value)
    end)
        :FromTo(height, savedTop)
        :Duration(openCloseDuration)
        :Easing(Easing.easeInOutSin)
        :OnComplete(onComplete)

    _myTween:Start()
end

--------------------------------
------  PUBLIC FUNCTIONS  ------
--------------------------------

function PlayOpenAnim(ui, onComplete: () -> () | nil, reverse: boolean | nil)
    if not ui then
        print("ERROR: No UI provided to PlayOpenAnim")
        return
    end

    local _root: VisualElement = ui.GetRoot()
    if _root == nil then return end

    _root.style.scale = StyleScale.new(Vector2.zero)

    local _startVal: number = 0
    local _endVal: number = 1
    local _easing = Easing.easeOutBack

    if reverse then
        _startVal = 1
        _endVal = 0
        _easing = Easing.easeInBack
    end

    local _myTween = Tween:new(function(value)
        _root.style.scale = StyleScale.new(Vector2.one * value)
    end)
        :FromTo(_startVal, _endVal)
        :Duration(openCloseDuration)
        :Easing(_easing)
        :OnComplete(function()
            if onComplete then onComplete() end
        end)

    _myTween:Start()
end

function PlaySlideUpAnim(ui, onComplete: () -> () | nil, reverse: boolean | nil)
    if not ui then
        print("ERROR: No UI provided to PlaySlideUpAnim")
        return
    end

    local _root: VisualElement = ui.GetRoot()
    if _root == nil then return end

    _root.style.opacity = StyleFloat.new(0)

    Timer.After(0.05, function()
        local _savedTop = _root.style.top.value.value
        _root.style.opacity = StyleFloat.new(1)
        playSlideUpWithHeight(_root, onComplete, _savedTop, ui.GetSize().y)
    end)
end
