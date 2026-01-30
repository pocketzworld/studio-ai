--!Type(Module)

--------------------------------
------  REQUIRED MODULES  ------
--------------------------------

local Tweener = require("Tweener")
local Tween = Tweener.Tween
local Easing = Tweener.Easing

--------------------------------
------  TYPE DEFINITIONS  ------
--------------------------------

export type UILabelData = {
    Root: VisualElement,
    Label: Label,
}

--------------------------------
------     LOCAL STATE    ------
--------------------------------

local spinAngle: number = 0

--------------------------------
------  LOCAL FUNCTIONS   ------
--------------------------------

local function baseSet(element, parent, classes: { string }, ignoreClick: boolean | nil)
    ParentElement(element, parent)
    for i, class in ipairs(classes) do
        AddClass(element, class)
    end
    local _ignore = ignoreClick
    if ignoreClick == nil then
        _ignore = true
    end
    SetPickingMode(element, _ignore)
end

--------------------------------
------  PUBLIC FUNCTIONS  ------
--------------------------------

function ParentElement(element, parent)
    if not element or not parent then return end
    parent:Add(element)
end

function AddClass(element, class: string)
    if not element or not class or class == "" then return end
    element:AddToClassList(class)
end

function RemoveClass(element, class: string)
    if not element or not class or class == "" then return end
    element:RemoveFromClassList(class)
end

function SetPickingMode(element, ignore: boolean)
    if not element then return end
    element.pickingMode = ignore and PickingMode.Ignore or PickingMode.Position
end

function NewVisualElement(parent, classes: { string }, ignoreClick: boolean | nil): VisualElement
    local _element = VisualElement.new()
    baseSet(_element, parent, classes, ignoreClick)
    return _element
end

function NewImage(parent, image: Texture, classes: { string }, ignoreClick: boolean | nil): Image
    local _element = Image.new()
    _element.image = image
    baseSet(_element, parent, classes, ignoreClick)
    return _element
end

function NewLoadedImage(parent, imageToLoad: string, classes: { string }, ignoreClick: boolean | nil): Image
    local _element = UIImage.new()
    _element:LoadItemPreview("avatar_item", imageToLoad)
    baseSet(_element, parent, classes, ignoreClick)
    return _element
end

function NewImageFromURL(parent, url: string, classes: { string }, ignoreClick: boolean | nil): UIImage
    local _element = UIImage.new()
    _element:LoadFromCdnUrl(url)
    baseSet(_element, parent, classes, ignoreClick)
    return _element
end

function NewLabel(parent, text: string, classes: { string }, ignoreClick: boolean | nil): Label
    local _element = Label.new()
    _element.text = text
    baseSet(_element, parent, classes, ignoreClick)
    return _element
end

function NewUserThumbnail(parent, playerId: string, classes: { string }, ignoreClick: boolean | nil): Label
    local _element = UIUserThumbnail.new()
    _element:Load(playerId)
    baseSet(_element, parent, classes, ignoreClick)
    return _element
end

function NewButton(parent, classes: { string }, ignoreClick: boolean | nil): Button
    local _element = Button.new()
    baseSet(_element, parent, classes, ignoreClick)
    return _element
end

function NewLoadingSpinner(parent, classes: { string }, darken: boolean | nil): (VisualElement, Tween)
    local _overlay = CreateModalOverlay(parent, nil, darken, false)
    AddClass(_overlay, "centered")
    local _element = VisualElement.new()
    if not classes then
        classes = { "loading-spinner" }
    end
    baseSet(_element, _overlay, classes, true)
    local _tween = PlaySpin(_element)
    return _overlay, _tween
end

function CreateModalOverlay(
    parent: VisualElement,
    onClick: () -> (),
    darken: boolean | nil,
    expand: boolean | nil
): VisualElement
    if not parent then
        print("ERROR: No parent provided to CreateModalOverlay")
        return nil
    end

    local _darkenClass = darken and "modal" or ""
    local _expandClass = expand and "expand" or "fill-parent"
    local _overlay = NewVisualElement(parent, { "absolute", _darkenClass, _expandClass }, false)
    parent:Insert(0, _overlay)
    if onClick then
        _overlay:RegisterCallback(PointerDownEvent, onClick)
    end
    return _overlay
end

function CreateClickBlocker(parent: VisualElement): VisualElement
    if not parent then
        print("ERROR: No parent provided to CreateClickBlocker")
        return nil
    end

    local _blocker = NewVisualElement(parent, { "absolute", "fill-parent" }, false)
    return _blocker
end

function CreateCollection(
    entryProviderFunction: UICollectionDelegateProvider,
    parent: VisualElement,
    collectionClass: string,
    itemCount: number,
    grid: boolean,
    spacing: number,
    columnCount: number | nil,
    isAsync: boolean | nil
): (UICollectionCells, UICollection)
    if not entryProviderFunction then
        print("ERROR: No entry provider provided to CreateCollection")
        return nil, nil
    end
    if not parent then
        print("ERROR: No parent provided to CreateCollection")
        return nil, nil
    end

    local _collection = UICollection.new()
    local _section = UICollectionSection.new()

    local _cells = UICollectionCells.new()
    if grid then
        _cells:SetLayout(UICollectionGridLayout.new(spacing, columnCount or 1))
    else
        _cells:SetLayout(UICollectionStackLayout.new(itemCount, spacing))
    end

    _section:Add(_cells)
    _collection:Add(_section)
    parent:Add(_collection)

    AddClass(_collection, collectionClass)
    _collection:InitializeSections()
    _cells.provider = entryProviderFunction

    if not isAsync then
        _collection:PerformUpdates(function()
            _cells:AddCells(itemCount)
        end)
    end

    _collection:ScrollToBeginning()
    return _cells, _collection
end

function CreateCurrencyUI(parent: VisualElement, sprite: Sprite): UILabelData
    if not parent then
        print("ERROR: No parent provided to CreateCurrencyUI")
        return nil
    end
    if not sprite then
        print("ERROR: No sprite provided to CreateCurrencyUI")
        return nil
    end

    local _content = NewVisualElement(parent, { "currency-content" }, false)
    local _background = NewVisualElement(_content, { "absolute", "currency-background" }, true)
    local _layout = NewVisualElement(_content, { "horizontal-layout", "centered" }, true)
    local _icon = NewImage(_layout, sprite.texture, { "currency-icon" }, true)
    local _label = NewLabel(_layout, "0", { "currency-label" }, true)
    ZeroMargin(_label)
    return { Root = _content, Label = _label }
end

function SetButtonEnabled(element: VisualElement, enabled: boolean, fadeOnDisable: boolean | nil)
    if not element then return end
    element:SetEnabled(enabled)
    if fadeOnDisable then
        element.style.opacity = StyleFloat.new(enabled and 1 or 0.3)
    end
end

function ShowElementByOpacity(element: VisualElement, show: boolean, ignoreClick: boolean | nil)
    if not element then return end
    element.style.opacity = StyleFloat.new(show and 1 or 0)
    if not show then
        SetPickingMode(element, true)
    else
        SetPickingMode(element, ignoreClick or true)
    end
end

function ZeroMargin(element: VisualElement)
    if not element then return end
    element.style.marginBottom = StyleLength.new(0)
    element.style.marginTop = StyleLength.new(0)
    element.style.marginLeft = StyleLength.new(0)
    element.style.marginRight = StyleLength.new(0)
end

function ZeroPadding(element: VisualElement)
    if not element then return end
    element.style.paddingBottom = StyleLength.new(0)
    element.style.paddingTop = StyleLength.new(0)
    element.style.paddingLeft = StyleLength.new(0)
    element.style.paddingRight = StyleLength.new(0)
end

function Padding(element: VisualElement, padding: number)
    if not element then return end
    element.style.paddingBottom = StyleLength.new(padding)
    element.style.paddingTop = StyleLength.new(padding)
    element.style.paddingLeft = StyleLength.new(padding)
    element.style.paddingRight = StyleLength.new(padding)
end

function Margin(element: VisualElement, margin: number)
    if not element then return end
    element.style.marginBottom = StyleLength.new(margin)
    element.style.marginTop = StyleLength.new(margin)
    element.style.marginLeft = StyleLength.new(margin)
    element.style.marginRight = StyleLength.new(margin)
end

function MarginAll(element: VisualElement, left: number, top: number, right: number, bottom: number)
    if not element then return end
    element.style.marginBottom = StyleLength.new(bottom)
    element.style.marginTop = StyleLength.new(top)
    element.style.marginLeft = StyleLength.new(left)
    element.style.marginRight = StyleLength.new(right)
end

function SetBorderColor(element: VisualElement, color: Color)
    if not element then return end
    element.style.borderBottomColor = StyleColor.new(color)
    element.style.borderTopColor = StyleColor.new(color)
    element.style.borderLeftColor = StyleColor.new(color)
    element.style.borderRightColor = StyleColor.new(color)
end

function ParentContainsClass(element: VisualElement, class: string): boolean
    if not element then return false end
    local _parent = element
    while _parent do
        if _parent:ClassListContains(class) then
            return true
        end
        _parent = _parent.parent
    end
    return false
end

function IsRTL(element: VisualElement): boolean
    if not element then return false end
    return ParentContainsClass(element, "rtl")
end

function PlaySpin(element: VisualElement): Tween
    if not element then
        print("ERROR: No element provided to PlaySpin")
        return nil
    end

    spinAngle = 0
    local _myTween = Tween:new(function(value)
        spinAngle = spinAngle + value * 5 * Time.deltaTime
        element.style.rotate = StyleRotate.new(Rotate.new(Angle.new(spinAngle)))
    end)
        :FromTo(0, 359)
        :Easing(Easing.linear)
        :Duration(0.1)
        :Loop()

    _myTween:Start()
    return _myTween
end
