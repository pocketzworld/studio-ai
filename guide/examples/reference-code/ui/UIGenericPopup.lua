--!Type(UI)

--------------------------------
------  REQUIRED MODULES  ------
--------------------------------

local UIManager = require("UIManager")

--!Bind
local _content: VisualElement = nil
--!Bind
local _message: Label = nil
--!Bind
local _okButton: UIButton = nil
--!Bind
local _okButtonText: Label = nil
--!Bind
local _cancelButton: UIButton = nil
--!Bind
local _closeOverlay: VisualElement = nil

--------------------------------
------     LOCAL STATE    ------
--------------------------------

local okCallback: () -> () = nil
local cancelCallback: () -> () = nil

--------------------------------
------  LOCAL FUNCTIONS   ------
--------------------------------

local function closeUI()
    UIManager.CloseUI(UIManager.UINames.GenericPopup)
end

local function onOkButton()
    if okCallback then
        okCallback()
    end
    closeUI()
end

local function onCancel()
    if cancelCallback then
        cancelCallback()
    end
    closeUI()
end

--------------------------------
------  PUBLIC FUNCTIONS  ------
--------------------------------

function GetRoot(): VisualElement
    return _content
end

function Init(message: string, onOkCallback: () -> ())
    if not message then
        print("ERROR: No message provided to Init")
        return
    end

    _message.text = message
    okCallback = onOkCallback

    _okButton:RegisterPressCallback(onOkButton)
    _cancelButton:SetDisplay(false)
    _closeOverlay:RegisterCallback(PointerDownEvent, closeUI)
end

function InitPurchase(message: string, ok: string, onOkCallback: () -> (), onCancelCallback: () -> ())
    if not message then
        print("ERROR: No message provided to InitPurchase")
        return
    end

    _message.text = message
    okCallback = onOkCallback
    cancelCallback = onCancelCallback

    _okButtonText.text = ok

    _okButton:RegisterPressCallback(onOkButton)
    _cancelButton:RegisterPressCallback(onCancel)
    _closeOverlay:RegisterCallback(PointerDownEvent, closeUI)
end
