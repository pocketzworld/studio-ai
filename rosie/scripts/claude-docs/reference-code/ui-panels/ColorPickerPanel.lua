--!Type(UI)

--!Bind
local _content: VisualElement = nil
--!Bind
local _closeButton: VisualElement = nil
--!Bind
local _rSlider: UISlider = nil
--!Bind
local _gSlider: UISlider = nil
--!Bind
local _bSlider: UISlider = nil
--!Bind
local _rValue: Label = nil
--!Bind
local _gValue: Label = nil
--!Bind
local _bValue: Label = nil
--!Bind
local _colorPreview: VisualElement = nil
--!Bind
local _rgbLabel: Label = nil
--!Bind
local _resetButton: VisualElement = nil
--!Bind
local _applyButton: VisualElement = nil

--------------------------------
------     CONSTANTS      ------
--------------------------------

local SLIDER_MIN = 0
local SLIDER_MAX = 255

--------------------------------
------     LOCAL STATE    ------
--------------------------------

local defaultColor: Color = Color.new(1, 1, 1)
local currentColor: Color = Color.new(1, 1, 1)

--------------------------------
------  LOCAL FUNCTIONS   ------
--------------------------------

local function rgbToColor(r: number, g: number, b: number): Color
    return Color.new(r / 255, g / 255, b / 255)
end

local function colorToRGB(color: Color): (number, number, number)
    return math.floor(color.r * 255), math.floor(color.g * 255), math.floor(color.b * 255)
end

local function updateColorPreview()
    local _r = _rSlider.value
    local _g = _gSlider.value
    local _b = _bSlider.value

    currentColor = rgbToColor(_r, _g, _b)

    _colorPreview.style.backgroundColor = StyleColor.new(currentColor)

    _rValue.text = tostring(_r)
    _gValue.text = tostring(_g)
    _bValue.text = tostring(_b)

    _rgbLabel.text = "RGB: " .. _r .. ", " .. _g .. ", " .. _b
end

local function onSliderChanged(event: IntChangeEvent)
    updateColorPreview()
end

local function onReset()
    local _r, _g, _b = colorToRGB(defaultColor)

    _rSlider.value = _r
    _gSlider.value = _g
    _bSlider.value = _b

    updateColorPreview()
end

local function onApply()
    defaultColor = currentColor

    print("Applied color: RGB(" ..
        math.floor(currentColor.r * 255) .. ", " ..
        math.floor(currentColor.g * 255) .. ", " ..
        math.floor(currentColor.b * 255) .. ")")

    onClose()
end

local function onClose()
    currentColor = defaultColor
    self.gameObject:SetActive(false)
end

local function initializeSliders()
    _rSlider.lowValue = SLIDER_MIN
    _rSlider.highValue = SLIDER_MAX

    _gSlider.lowValue = SLIDER_MIN
    _gSlider.highValue = SLIDER_MAX

    _bSlider.lowValue = SLIDER_MIN
    _bSlider.highValue = SLIDER_MAX

    local _r, _g, _b = colorToRGB(defaultColor)
    _rSlider.value = _r
    _gSlider.value = _g
    _bSlider.value = _b

    _rSlider:RegisterCallback(IntChangeEvent, onSliderChanged)
    _gSlider:RegisterCallback(IntChangeEvent, onSliderChanged)
    _bSlider:RegisterCallback(IntChangeEvent, onSliderChanged)
end

--------------------------------
------  PUBLIC FUNCTIONS  ------
--------------------------------

function SetColor(color: Color)
    if not color then
        print("ERROR: No color provided to SetColor")
        return
    end

    defaultColor = color
    currentColor = color

    local _r, _g, _b = colorToRGB(color)
    _rSlider:SetValueWithoutNotify(_r)
    _gSlider:SetValueWithoutNotify(_g)
    _bSlider:SetValueWithoutNotify(_b)

    updateColorPreview()
end

function GetColor(): Color
    return currentColor
end

function Init()
    initializeSliders()
    updateColorPreview()

    _closeButton:RegisterPressCallback(onClose)
    _resetButton:RegisterPressCallback(onReset)
    _applyButton:RegisterPressCallback(onApply)
end

--------------------------------
------  LIFECYCLE HOOKS   ------
--------------------------------

function self:OnEnable()
    Init()
end

function self:Awake()
    -- Callbacks can also be registered in Awake
end
