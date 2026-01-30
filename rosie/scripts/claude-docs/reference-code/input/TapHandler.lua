--!Type(Client)

--------------------------------
------     LOCAL STATE    ------
--------------------------------

local camera: Camera = nil
local onTapCallback: ((Vector2, GameObject?) -> ())? = nil

--------------------------------
------  PUBLIC FUNCTIONS  ------
--------------------------------

function ScreenToWorldRaycast(screenPosition: Vector2, layerMask: LayerMask?): (boolean, Vector3, RaycastHit?)
    if not screenPosition then
        print("ERROR: No screen position provided to ScreenToWorldRaycast")
        return false, Vector3.zero, nil
    end

    if not camera then
        camera = Camera.main
    end

    local _ray = camera:ScreenPointToRay(screenPosition)
    local _hitSuccess: boolean
    local _hitInfo: RaycastHit

    if layerMask then
        _hitSuccess, _hitInfo = Physics.Raycast(_ray, math.huge, layerMask)
    else
        _hitSuccess, _hitInfo = Physics.Raycast(_ray)
    end

    if _hitSuccess then
        return true, _hitInfo.point, _hitInfo
    end

    return false, Vector3.zero, nil
end

function ScreenToGroundPlane(screenPosition: Vector2, planeHeight: number?): Vector3
    if not screenPosition then
        print("ERROR: No screen position provided to ScreenToGroundPlane")
        return Vector3.zero
    end

    if not camera then
        camera = Camera.main
    end

    local _height = planeHeight or 0
    local _groundPlane = Plane.new(Vector3.up, Vector3.new(0, _height, 0))
    local _ray = camera:ScreenPointToRay(screenPosition)

    local _success, _distance = _groundPlane:Raycast(_ray)
    if _success then
        return _ray:GetPoint(_distance)
    end

    return Vector3.zero
end

function GetTappedObject(screenPosition: Vector2): GameObject?
    if not screenPosition then
        print("ERROR: No screen position provided to GetTappedObject")
        return nil
    end

    if not camera then
        camera = Camera.main
    end

    local _ray = camera:ScreenPointToRay(screenPosition)
    local _hitSuccess: boolean
    local _hitInfo: RaycastHit

    _hitSuccess, _hitInfo = Physics.Raycast(_ray)

    if _hitSuccess then
        return _hitInfo.collider.gameObject
    end

    return nil
end

function GetTappedComponent<T>(screenPosition: Vector2): T?
    if not screenPosition then
        print("ERROR: No screen position provided to GetTappedComponent")
        return nil
    end

    local _obj = GetTappedObject(screenPosition)
    if _obj then
        return _obj:GetComponent(T)
    end
    return nil
end

function RegisterTapHandler(callback: (Vector2, GameObject?) -> ())
    if not callback then
        print("ERROR: No callback provided to RegisterTapHandler")
        return
    end
    onTapCallback = callback
end

--------------------------------
------  LIFECYCLE HOOKS   ------
--------------------------------

function self:ClientStart()
    camera = Camera.main

    Input.Tapped:Connect(function(evt)
        local _hitObject = GetTappedObject(evt.position)

        if onTapCallback then
            onTapCallback(evt.position, _hitObject)
        end
    end)
end
