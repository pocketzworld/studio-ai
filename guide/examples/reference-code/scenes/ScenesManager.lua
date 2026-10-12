--!Type(UI)

--------------------------------
------  REQUIRED MODULES  ------
--------------------------------

local events = require("HRLiveUtils")

--------------------------------
------  SERIALIZED FIELDS ------
--------------------------------

--!SerializeField
local scenesList: { string } = nil

--!Bind
local _title: Label = nil
--!Bind
local _closeButton: VisualElement = nil
--!Bind
local _container: VisualElement = nil

--------------------------------
------     LOCAL STATE    ------
--------------------------------

local parentPanel = nil

--------------------------------
------  PUBLIC FUNCTIONS  ------
--------------------------------

function Show()
    self.enabled = true
end

function Hide()
    self.enabled = false
end

function Return()
    if parentPanel then
        parentPanel.OnChildClosed()
    end
    self.gameObject:SetActive(false)
end

function OnChildOpened()
    Hide()
end

function OnChildClosed()
    Show()
end

function LoadScene(sceneID: number)
    if not sceneID then
        print("ERROR: No scene ID provided to LoadScene")
        return
    end
    print("Loading scene: " .. sceneID)
    events.SceneChangeRequest:FireServer(sceneID)
end

--------------------------------
------  LIFECYCLE HOOKS   ------
--------------------------------

function self:OnEnable()
    _title.text = self.gameObject.name:gsub("(%u)", " %1"):gsub("^%s", "")

    if self.transform.parent then
        local _parent = self.transform.parent.gameObject
        parentPanel = _parent:GetComponent(HRLiveToolkitUI) or _parent:GetComponent(MultiOptionPanel)
    end
end

function self:Start()
    for index, sceneName in ipairs(scenesList) do
        local _newButton = VisualElement.new()
        _newButton:AddToClassList("module_button")
        _container:Add(_newButton)

        local _label = Label.new("Load " .. sceneName)
        _label:AddToClassList("button_label")
        _newButton:Add(_label)

        _newButton:RegisterPressCallback(function()
            LoadScene(index - 1)
        end)
    end
end

_closeButton:RegisterPressCallback(Return)
