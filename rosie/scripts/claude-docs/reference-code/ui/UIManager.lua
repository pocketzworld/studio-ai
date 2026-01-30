--!Type(Module)

--------------------------------
------  REQUIRED MODULES  ------
--------------------------------

local AnimateHelper = require("UIPopupAnimateHelper")
local UIUtils: UIUtils = require("UIUtils")

--------------------------------
------  SERIALIZED FIELDS ------
--------------------------------

--!SerializeField
local coreStyleSheet: StyleSheet = nil
--!SerializeField
local genericPopupPrefab: GameObject = nil
--!SerializeField
local gameHUDPrefab: GameObject = nil
--!SerializeField
local optionsMenuPrefab: GameObject = nil
--!SerializeField
local popupOpenSound: AudioShader = nil
--!SerializeField
local popupCloseSound: AudioShader = nil

--------------------------------
------    GLOBAL STATE    ------
--------------------------------

-- Exposed globally for other UI scripts to reference UI states
UIState = {
    Open = 1,
    Closed = 2,
    Closing = 3,
}

type UIData = {
    UI: GameObject,
    Component: any,
    State: number,
    AnimType: number,
}

AnimType = {
    None = 0,
    ScaleUp = 1,
    SlideUp = 2,
}

-- Exposed globally for other UI scripts to reference UI by name
UINames = {
    GenericPopup = "GenericPopup",
    GameHUD = "GameHUD",
    OptionsMenu = "OptionsMenu",
}

--------------------------------
------     NETWORKING     ------
--------------------------------

UIOpenedEvent = Event.new("UIOpenedEvent")
UIClosedEvent = Event.new("UIClosedEvent")

--------------------------------
------     LOCAL STATE    ------
--------------------------------

local uiData: { [string]: UIData } = {}

--------------------------------
------  LOCAL FUNCTIONS   ------
--------------------------------

local function destroyUI(ui: GameObject)
    Object.Destroy(ui)
end

local function shutdownUI(data: UIData, id: string)
    if data.Component.Cleanup ~= nil then
        data.Component.Cleanup()
    end
    data.State = UIState.Closed
    destroyUI(data.UI)
    uiData[id] = nil
    UIClosedEvent:Fire(id)
end

--------------------------------
------  PUBLIC FUNCTIONS  ------
--------------------------------

function AddCoreStyleSheetToElement(element: VisualElement)
    if not element then
        print("ERROR: No element provided to AddCoreStyleSheetToElement")
        return
    end
    if element and coreStyleSheet then
        element:AddStyleSheet(coreStyleSheet)
    end
end

function DoAnimation(ui, animType: number, onComplete: () -> () | nil, reverse: boolean | nil)
    local _animated = animType > AnimType.None
    if _animated then
        if animType == AnimType.ScaleUp then
            AnimateHelper.PlayOpenAnim(ui, onComplete, reverse)
        elseif animType == AnimType.SlideUp then
            AnimateHelper.PlaySlideUpAnim(ui, onComplete, reverse)
        end
    end
end

function SetUIData(data: UIData, component, animType: number)
    if not data then
        print("ERROR: No data provided to SetUIData")
        return
    end
    data.Component = component
    data.AnimType = animType
    if component.GetRoot then
        local _root: VisualElement = component.GetRoot()
        AddCoreStyleSheetToElement(_root.parent)
    end
    DoAnimation(component, animType)
end

function OpenPopup(uiObj: GameObject, id: string, playOpenSound: boolean?): GameObject
    if not uiObj then
        print("ERROR: No UI object provided to OpenPopup")
        return nil
    end
    if not id then
        print("ERROR: No ID provided to OpenPopup")
        return nil
    end

    local _newUI = GameObject.Instantiate(uiObj)

    local _data = {
        UI = _newUI,
        State = UIState.Open,
    }

    uiData[id] = _data

    if popupOpenSound and (playOpenSound or playOpenSound == nil) then
        popupOpenSound:Play()
    end

    UIOpenedEvent:Fire(id)
    return _newUI
end

function OpenGenericPopupUI(message: string, callback): UIGenericPopup
    if not message then
        print("ERROR: No message provided to OpenGenericPopupUI")
        return nil
    end

    local _ui = OpenPopup(genericPopupPrefab, UINames.GenericPopup)
    local _popup = _ui:GetComponent(UIGenericPopup)
    SetUIData(uiData[UINames.GenericPopup], _popup, AnimType.ScaleUp)
    _popup.Init(message, callback)
    return _popup
end

function OpenGenericPopupWithCancelUI(message: string, callback, cancelCallback): UIGenericPopup
    if not message then
        print("ERROR: No message provided to OpenGenericPopupWithCancelUI")
        return nil
    end

    local _ui = OpenPopup(genericPopupPrefab, UINames.GenericPopup)
    local _popup = _ui:GetComponent(UIGenericPopup)
    SetUIData(uiData[UINames.GenericPopup], _popup, AnimType.ScaleUp)
    _popup.InitPurchase(message, callback, cancelCallback)
    return _popup
end

function OpenGameHUDUI(): UIHUD
    if IsUIOpen(UINames.GameHUD) then
        return GetUI(UINames.GameHUD)
    end

    local _ui = OpenPopup(gameHUDPrefab, UINames.GameHUD, false)
    local _popup = _ui:GetComponent(UIHUD)
    SetUIData(uiData[UINames.GameHUD], _popup, AnimType.None)
    return _popup
end

function IsUIOpen(id: string): boolean
    if not id then
        print("ERROR: No ID provided to IsUIOpen")
        return false
    end

    local _data = uiData[id]
    return _data and _data.State ~= UIState.Closed
end

function GetUI(id: string): any
    if not id then
        print("ERROR: No ID provided to GetUI")
        return nil
    end

    local _data = uiData[id]
    if not _data then return nil end
    return _data.Component
end

function GetHUD(): UIHUD
    return GetUI(UINames.GameHUD)
end

function ShowUI(id: string, show: boolean)
    if not id then
        print("ERROR: No ID provided to ShowUI")
        return
    end

    local _data = uiData[id]
    if not _data or not _data.Component or not _data.Component.GetRoot then return end
    local _root: VisualElement = _data.Component.GetRoot()
    _root:SetDisplay(show)
end

function GetOpenUICount(ignoredId: string): number
    local _count = 0
    for id, data in pairs(uiData) do
        if id ~= ignoredId and data.State == UIState.Open then
            _count = _count + 1
        end
    end
    return _count
end

function CloseUI(id: string, forceClose: boolean | nil, callback: () -> () | nil)
    if not id then
        print("ERROR: No ID provided to CloseUI")
        return
    end

    local _data = uiData[id]
    if not _data then return end

    if _data and _data.State ~= UIState.Closed then
        if not forceClose and _data.AnimType > AnimType.None and _data.State == UIState.Open then
            if _data.Component.GetRoot == nil then
                print("ERROR: Component does not have GetRoot function")
                if callback then callback() end
                shutdownUI(_data, id)
                return
            end

            _data.State = UIState.Closing
            local _clickBlocker = UIUtils.CreateClickBlocker(_data.Component.GetRoot())

            DoAnimation(_data.Component, _data.AnimType, function()
                if _data and _data.Component then
                    shutdownUI(_data, id)
                    if callback then callback() end
                end
                _clickBlocker:RemoveFromHierarchy()
            end, true)

            if popupCloseSound then
                popupCloseSound:Play()
            end
        else
            shutdownUI(_data, id)
            if callback then callback() end
        end
    end
end
