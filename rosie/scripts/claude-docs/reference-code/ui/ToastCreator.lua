--!Type(Client)

--------------------------------
------  REQUIRED MODULES  ------
--------------------------------

local UIUtils: UIUtils = require("UIUtils")
local Utils: Utils = require("Utils")
local TweenModule = require("Tweener")
local Tween = TweenModule.Tween
local Easing = TweenModule.Easing

--------------------------------
------  TYPE DEFINITIONS  ------
--------------------------------

export type ToastInitData = {
    Text: string,
    Image: Texture2D,
    PlayerId: string,
    OnClickedCallback: () -> (),
}

--------------------------------
------  SERIALIZED FIELDS ------
--------------------------------

--!SerializeField
local maxToasts: number = 4
--!SerializeField
local toastSound: AudioShader = nil
--!SerializeField
local slideAnimDuration: number = 0.25
--!SerializeField
local stayDuration: number = 4
--!SerializeField
local extraSlidePadding: number = 10

--------------------------------
------     LOCAL STATE    ------
--------------------------------

local initData: ToastInitData = nil
local parentContainer: VisualElement = nil
local toastEntries: { VisualElement } = {}

--------------------------------
------  LOCAL FUNCTIONS   ------
--------------------------------

local function onToastClicked()
    if initData.OnClickedCallback then
        initData.OnClickedCallback()
    end
end

local function createEntry(): VisualElement
    local _toastEntry = UIUtils.NewVisualElement(parentContainer, { "toast-entry", "horizontal-layout" }, false)
    _toastEntry.pickingMode = PickingMode.Position

    local _avatarImage = UIUtils.NewUserThumbnail(_toastEntry, initData.PlayerId, { "playerIcon" })

    local _text = UIUtils.NewLabel(_toastEntry, initData.Text, { "toast-text" })

    if initData.Image then
        local _questImage: Image = UIUtils.NewImage(_toastEntry, initData.Image, { "toast-image" })
    end

    _toastEntry:RegisterPressCallback(function()
        onToastClicked()
    end)

    table.insert(toastEntries, _toastEntry)
    return _toastEntry
end

local function removeEntry(entry: VisualElement)
    if not Utils.IsInTable(toastEntries, entry) then
        return
    end
    parentContainer:Remove(entry)
    Utils.RemoveInTable(toastEntries, entry)
end

local function showToast(entry: VisualElement)
    if toastSound then
        Audio:PlaySoundGlobal(toastSound, 1, 1, false)
    end

    Timer.After(stayDuration, function()
        PlayFadeOutAnim(entry, function()
            removeEntry(entry)
        end)
    end)
end

--------------------------------
------  PUBLIC FUNCTIONS  ------
--------------------------------

function PlaySlideInAnim(content: VisualElement, onComplete: () -> () | nil)
    if not content then
        print("ERROR: No content provided to PlaySlideInAnim")
        return
    end

    local _startTop = -content.layout.height + extraSlidePadding
    content.style.top = StyleLength.new(Length.new(_startTop))

    local _myTween = Tween:new(function(value)
        local _top = Utils.LerpNoClamp(_startTop, extraSlidePadding, value)
        content.style.top = StyleLength.new(Length.new(_top))
    end)
        :FromTo(0, 1)
        :Easing(Easing.easeOutBack)
        :Duration(slideAnimDuration)
        :OnComplete(onComplete)

    _myTween:Start()
end

function PlaySlideOutAnim(content: VisualElement, onComplete: () -> () | nil)
    if not content then
        print("ERROR: No content provided to PlaySlideOutAnim")
        return
    end

    local _startTop = extraSlidePadding
    content.style.top = StyleLength.new(Length.new(_startTop))

    local _myTween = Tween:new(function(value)
        local _top = Utils.LerpNoClamp(_startTop, -content.layout.width, value)
        content.style.top = StyleLength.new(Length.new(_top))
    end)
        :FromTo(0, 1)
        :Easing(Easing.easeInBack)
        :Duration(slideAnimDuration)
        :OnComplete(onComplete)

    _myTween:Start()
end

function PlayFadeOutAnim(content: VisualElement, onComplete: () -> () | nil)
    if not content then
        print("ERROR: No content provided to PlayFadeOutAnim")
        return
    end

    local _myTween = Tween:new(function(value)
        content.style.opacity = StyleFloat.new(1 - value)
    end)
        :FromTo(0, 1)
        :Easing(Easing.easeInQuad)
        :Duration(slideAnimDuration)
        :OnComplete(onComplete)

    _myTween:Start()
end

function CreateToast(toastInitData: ToastInitData, toastParentContainer: VisualElement)
    if not toastInitData then
        print("ERROR: No init data provided to CreateToast")
        return
    end
    if not toastParentContainer then
        print("ERROR: No parent container provided to CreateToast")
        return
    end

    initData = toastInitData
    parentContainer = toastParentContainer

    local _entry = createEntry()
    showToast(_entry)

    if #toastEntries > maxToasts then
        local _entryToRemove = toastEntries[1]
        removeEntry(_entryToRemove)
    end
end
