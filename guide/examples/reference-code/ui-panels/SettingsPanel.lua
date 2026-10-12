--!Type(UI)

--------------------------------
------  REQUIRED MODULES  ------
--------------------------------

local UIUtils = require("UIUtils")

--!Bind
local _content: VisualElement = nil
--!Bind
local _closeButton: VisualElement = nil
--!Bind
local _musicToggle: UISwitchToggle = nil
--!Bind
local _sfxToggle: UISwitchToggle = nil
--!Bind
local _volumeSlider: UISlider = nil
--!Bind
local _volumeLabel: Label = nil
--!Bind
local _sensitivitySlider: UISlider = nil
--!Bind
local _sensitivityLabel: Label = nil

--------------------------------
------     CONSTANTS      ------
--------------------------------

local VOLUME_MIN = 0
local VOLUME_MAX = 100
local SENSITIVITY_MIN = 1
local SENSITIVITY_MAX = 10

--------------------------------
------     LOCAL STATE    ------
--------------------------------

local settings: table = {
    MusicEnabled = true,
    SfxEnabled = true,
    Volume = 50,
    Sensitivity = 5,
}

--------------------------------
------  LOCAL FUNCTIONS   ------
--------------------------------

local function onMusicToggleChanged(event: BoolChangeEvent)
    settings.MusicEnabled = event.newValue
    print("Music: " .. tostring(event.newValue))
end

local function onSfxToggleChanged(event: BoolChangeEvent)
    settings.SfxEnabled = event.newValue
    print("SFX: " .. tostring(event.newValue))
end

local function onVolumeSliderChanged(event: IntChangeEvent)
    local _value = _volumeSlider.value
    settings.Volume = _value
    _volumeLabel.text = tostring(_value) .. "%"
end

local function onSensitivitySliderChanged(event: IntChangeEvent)
    local _value = _sensitivitySlider.value
    settings.Sensitivity = _value
    _sensitivityLabel.text = tostring(_value)
end

local function onCloseButton()
    Cleanup()
    self.gameObject:SetActive(false)
end

local function initializeSliders()
    _volumeSlider.lowValue = VOLUME_MIN
    _volumeSlider.highValue = VOLUME_MAX
    _volumeSlider.value = settings.Volume
    _volumeLabel.text = tostring(settings.Volume) .. "%"

    _sensitivitySlider.lowValue = SENSITIVITY_MIN
    _sensitivitySlider.highValue = SENSITIVITY_MAX
    _sensitivitySlider.value = settings.Sensitivity
    _sensitivityLabel.text = tostring(settings.Sensitivity)
end

local function initializeToggles()
    _musicToggle.value = settings.MusicEnabled
    _sfxToggle.value = settings.SfxEnabled
end

local function loadSettings()
    initializeToggles()
    initializeSliders()
end

--------------------------------
------  PUBLIC FUNCTIONS  ------
--------------------------------

function GetRoot(): VisualElement
    return _content
end

function Cleanup()
    -- Save settings to storage if needed
end

function Init()
    UIUtils.CreateModalOverlay(view, onCloseButton, true, true)

    _closeButton:RegisterPressCallback(onCloseButton)

    _musicToggle:RegisterCallback(BoolChangeEvent, onMusicToggleChanged)
    _sfxToggle:RegisterCallback(BoolChangeEvent, onSfxToggleChanged)

    _volumeSlider:RegisterCallback(IntChangeEvent, onVolumeSliderChanged)
    _sensitivitySlider:RegisterCallback(IntChangeEvent, onSensitivitySliderChanged)

    loadSettings()
end

--------------------------------
------  LIFECYCLE HOOKS   ------
--------------------------------

function self:OnEnable()
    Init()
end
