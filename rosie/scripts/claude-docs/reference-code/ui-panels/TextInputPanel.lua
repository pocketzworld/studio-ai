--!Type(UI)

--!Bind
local _content: VisualElement = nil
--!Bind
local _closeButton: VisualElement = nil
--!Bind
local _searchField: UITextField = nil
--!Bind
local _nameField: UITextField = nil
--!Bind
local _amountField: UITextField = nil
--!Bind
local _messageField: UITextField = nil
--!Bind
local _submitButton: VisualElement = nil
--!Bind
local _resultsContainer: VisualElement = nil

--------------------------------
------  LOCAL FUNCTIONS   ------
--------------------------------

local function filterNumbersOnly(str: string): string
    return string.gsub(str, "%D", "")
end

local function filterLettersOnly(str: string): string
    return string.gsub(str, "[^%a%s]", "")
end

local function limitLength(str: string, maxLength: number): string
    if #str > maxLength then
        return string.sub(str, 1, maxLength)
    end
    return str
end

local function onSearchChanged(event: StringChangeEvent)
    local _searchText = _searchField.textElement.text

    if _searchText == "" then
        _resultsContainer:Clear()
        return
    end

    print("Searching for: " .. _searchText)
end

local function onNameChanged(event: StringChangeEvent)
    local _text = _nameField.textElement.text
    local _filtered = filterLettersOnly(_text)
    _filtered = limitLength(_filtered, 20)

    if _filtered ~= _text then
        _nameField.textElement.text = _filtered
    end
end

local function onAmountChanged(event: StringChangeEvent)
    local _text = _amountField.textElement.text
    local _filtered = filterNumbersOnly(_text)

    if _filtered ~= _text then
        _amountField.textElement.text = _filtered
    end
end

local function onMessageChanged(event: StringChangeEvent)
    local _text = _messageField.textElement.text
    local _limited = limitLength(_text, 200)

    if _limited ~= _text then
        _messageField.textElement.text = _limited
    end
end

local function onSubmit()
    local _name = _nameField.value
    local _amount = tonumber(_amountField.value) or 0
    local _message = _messageField.value

    if _name == "" then
        print("Name is required")
        return
    end

    if _amount <= 0 then
        print("Invalid amount")
        return
    end

    print("Submitted: " .. _name .. ", " .. tostring(_amount) .. ", " .. _message)

    _nameField:SetValueWithoutNotify("")
    _amountField:SetValueWithoutNotify("")
    _messageField:SetValueWithoutNotify("")
end

local function onClose()
    self.gameObject:SetActive(false)
end

local function createTextField(parent: VisualElement, placeholder: string, classes: {string}?): UITextField
    local _textField = UITextField.new()

    if classes then
        for _, class in ipairs(classes) do
            _textField:AddToClassList(class)
        end
    end

    _textField:SetPlaceholderText(placeholder)
    parent:Add(_textField)

    return _textField
end

local function createNumberField(parent: VisualElement, placeholder: string): UITextField
    local _textField = createTextField(parent, placeholder, {"number-input"})

    _textField:RegisterCallback(StringChangeEvent, function(event)
        local _text = _textField.textElement.text
        local _filtered = filterNumbersOnly(_text)
        if _filtered ~= _text then
            _textField.textElement.text = _filtered
        end
    end)

    return _textField
end

local function configureSearchField()
    _searchField:SetPlaceholderText("Search players...")
    _searchField.showSearchIcon = true
    _searchField.showClearButton = true
    _searchField:RegisterCallback(StringChangeEvent, onSearchChanged)
end

local function configureNameField()
    _nameField:SetPlaceholderText("Enter your name")
    _nameField.maxLength = 20
    _nameField:RegisterCallback(StringChangeEvent, onNameChanged)
end

local function configureAmountField()
    _amountField:SetPlaceholderText("Amount")
    _amountField.maxLength = 6
    _amountField:RegisterCallback(StringChangeEvent, onAmountChanged)
end

local function configureMessageField()
    _messageField:SetPlaceholderText("Enter a message (optional)")
    _messageField.multiline = true
    _messageField.maxLength = 200
    _messageField:RegisterCallback(StringChangeEvent, onMessageChanged)
end

--------------------------------
------  PUBLIC FUNCTIONS  ------
--------------------------------

function Init()
    configureSearchField()
    configureNameField()
    configureAmountField()
    configureMessageField()

    _submitButton:RegisterPressCallback(onSubmit)
    _closeButton:RegisterPressCallback(onClose)
end

function IsAnyTextFieldFocused(): boolean
    return UITextField.IsTextFieldFocused()
end

function GetFocusedTextField(): UITextField?
    return UITextField.FocusedTextField()
end

--------------------------------
------  LIFECYCLE HOOKS   ------
--------------------------------

function self:OnEnable()
    Init()
end
