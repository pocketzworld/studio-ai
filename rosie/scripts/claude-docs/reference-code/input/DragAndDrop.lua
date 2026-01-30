--!Type(Module)

--------------------------------
------  REQUIRED MODULES  ------
--------------------------------

local TweenModule = require("TweenModule")
local Tween = TweenModule.Tween

--------------------------------
------  SERIALIZED FIELDS ------
--------------------------------

--!SerializeField
local lagDistanceLimit: number = 2
--!SerializeField
local momentumLimit: number = 0.1
--!SerializeField
local momentumDecay: number = 3

--------------------------------
------     LOCAL STATE    ------
--------------------------------

local camera: Camera = nil
local camScript: RTSCameraOverride = nil
local isDragging: boolean = false
local hoverOffset: Vector3 = Vector3.up
local draggableObject: GameObject = nil
local swingMomentum: Vector3 = Vector3.zero

local dragNavMeshAgent: NavMeshAgent = nil
local dragCapsuleCollider: CapsuleCollider = nil
local startPos: Vector3 = nil
local dragCharacter: Character = nil
local touchWorldPos: Vector3 = nil
local inVoid: boolean = nil
local touchScreenPos: Vector2 = nil
local lastScreenPos: Vector2 = nil
local targetPlayerPos: Vector3 = nil

--------------------------------
------  LOCAL FUNCTIONS   ------
--------------------------------

local function screenPositionToWorldPoint(screenPosition: Vector2, flipY: boolean): (Vector3, boolean, RaycastHit)
    local _worldUpPlane = Plane.new(Vector3.up, Vector3.new(0, 0, 0))

    if flipY then
        screenPosition.y = Screen.height - screenPosition.y
    end

    local _ray = camScript.GetCamera():ScreenPointToRay(screenPosition)
    local _hitSuccess: boolean
    local _hitInfo: RaycastHit

    _hitSuccess, _hitInfo = Physics.Raycast(_ray)

    if _hitSuccess then
        return _hitInfo.point, false, _hitInfo
    else
        local _success, _distance = _worldUpPlane:Raycast(_ray)
        if not _success then
            return Vector3.zero, true
        end
        return _ray:GetPoint(_distance), true
    end
end

local function raycastFromScreen(screenPosition: Vector2): GameObject
    local _ray = camScript.GetCamera():ScreenPointToRay(screenPosition)
    local _hitSuccess: boolean
    local _hitInfo: RaycastHit

    _hitSuccess, _hitInfo = Physics.Raycast(_ray)

    if _hitSuccess then
        return _hitInfo.collider.gameObject
    end

    return nil
end

local function onDragBegan(evt)
    if draggableObject then
        return
    end

    local _touchedObject = raycastFromScreen(evt.position)

    if _touchedObject then
        draggableObject = _touchedObject
        dragCharacter = draggableObject:GetComponent(Character)

        if not dragCharacter then
            print(draggableObject.name .. " is not a valid character")
            draggableObject = nil
            return
        end

        dragCharacter:PlayEmote("emote-bobble", true)

        if dragCharacter.isAnchored then
            dragCharacter:Teleport(dragCharacter.transform.position)
        end

        touchScreenPos = evt.position
        lastScreenPos = touchScreenPos
        isDragging = true
        startPos = draggableObject.transform.position

        local _baseOrthoSize = 5
        local _offsetFactor = 0.6
        local _normalizedOrthoSize = camScript.GetCamera().orthographicSize / _baseOrthoSize
        local _verticalOffset = (Screen.height * _offsetFactor) / (_normalizedOrthoSize * 2)
        touchWorldPos, inVoid = screenPositionToWorldPoint(evt.position + (Vector2.down * _verticalOffset))
        targetPlayerPos = touchWorldPos + hoverOffset

        dragNavMeshAgent = draggableObject:GetComponent(NavMeshAgent)
        dragCapsuleCollider = draggableObject:GetComponent(CapsuleCollider)

        if dragNavMeshAgent then
            dragNavMeshAgent.enabled = false
        end
        if dragCapsuleCollider then
            dragCapsuleCollider.enabled = false
        end

        camScript.enabled = false
    end
end

local function onDrag(evt)
    if not isDragging then return end

    local _baseOrthoSize = 5
    local _offsetFactor = 0.6
    local _normalizedOrthoSize = camScript.GetCamera().orthographicSize / _baseOrthoSize
    local _verticalOffset = (Screen.height * _offsetFactor) / (_normalizedOrthoSize * 2)
    touchWorldPos, inVoid = screenPositionToWorldPoint(evt.position + (Vector2.down * _verticalOffset))

    touchScreenPos = evt.position
    if not lastScreenPos then lastScreenPos = touchScreenPos end
    lastScreenPos = touchScreenPos
    targetPlayerPos = touchWorldPos + hoverOffset

    if dragNavMeshAgent and dragNavMeshAgent.enabled then
        dragNavMeshAgent.enabled = false
    end
end

local function onDragEnded(evt)
    camScript.enabled = true

    if draggableObject == nil then
        return
    end

    if isDragging then
        isDragging = false
    end

    if dragNavMeshAgent then
        dragNavMeshAgent.enabled = true
    end
    if dragCapsuleCollider then
        dragCapsuleCollider.enabled = true
    end

    if inVoid then
        draggableObject.transform.position = startPos
        draggableObject = nil
        return
    end

    dragCharacter:StopEmote()

    local _dropPlayer = dragCharacter.player
    local _dropPlayerStart = draggableObject.transform.position
    local _dropPlayerEnd = _dropPlayerStart - hoverOffset

    local _dropTween = Tween:new(
        0, 1, 0.5,
        false, false,
        TweenModule.Easing.bounce,
        function(value, t)
            draggableObject.transform.position = Vector3.Lerp(_dropPlayerStart, _dropPlayerEnd, value)
        end,
        function()
            draggableObject.transform.position = _dropPlayerEnd
            draggableObject = nil
        end
    )
    _dropTween:Start()
end

--------------------------------
------  LIFECYCLE HOOKS   ------
--------------------------------

function self:Update()
    if isDragging and targetPlayerPos and draggableObject then
        local _lastPos = draggableObject.transform.position

        swingMomentum = Vector3.ClampMagnitude(
            swingMomentum + (targetPlayerPos - _lastPos) * Time.deltaTime,
            momentumLimit
        )

        draggableObject.transform.position = Vector3.Lerp(
            _lastPos + swingMomentum,
            targetPlayerPos,
            Time.deltaTime * momentumDecay
        )

        if Vector3.Distance(draggableObject.transform.position, targetPlayerPos) > lagDistanceLimit then
            draggableObject.transform.position = targetPlayerPos +
                (draggableObject.transform.position - targetPlayerPos).normalized * lagDistanceLimit
        end
    end
end

function self:ClientStart()
    camScript = self:GetComponent(RTSCameraOverride)

    Input.PinchOrDragBegan:Connect(onDragBegan)
    Input.PinchOrDragChanged:Connect(onDrag)
    Input.PinchOrDragEnded:Connect(onDragEnded)
end
