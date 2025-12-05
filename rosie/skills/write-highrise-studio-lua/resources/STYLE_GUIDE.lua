--!Type(...)

-- Not all sections are required for all scripts. Only include sections that have something in them. You can remove all of the guidance comments.

--------------------------------
------ SERIALIZED FIELDS  ------
--------------------------------
-- SerializeField allows the value to be adjusted in the editor
-- SerializeField variables must have a type annotation
--!SerializeField
local prefabObject: GameObject = nil

--------------------------------
------     CONSTANTS      ------
--------------------------------
-- Use SCREAMING_SNAKE_CASE for constants
-- Never use magic numbers; always use a constant
local MAX_LEVEL = 20

--------------------------------
------  REQUIRED MODULES  ------
--------------------------------
-- Module imports don't pull their fields into the global namespace. You would get a field from PlayerTracker via `playerTracker.FIELD_NAME`.
local playerTracker = require("PlayerTracker")
local monsterLibrary = require("MonsterLibrary")

--------------------------------
------     NETWORKING     ------
--------------------------------
-- Include all networked values and events here
-- Events used only in this script should be declared with `local`, use camelCase, and end in `Request`, `Event`, or `Response`
local myEvent = Event.new("MyEvent")

-- Events exposed globally should use PascalCase, and end in `Request`, `Event`, or `Response`
MyPublicEvent = Event.new("MyPublicEvent")

-- Networked values used only in this script should be declared with `local`, use camelCase, and end in `Value`
local myNetworkedValue = IntValue.new("MyNetworkedValue")

-- Networked values exposed globally should use PascalCase, and end in `Value`
MyPublicNetworkedValue = IntValue.new("MyPublicNetworkedValue")

--------------------------------
------    GLOBAL STATE    ------
--------------------------------
-- Minimize the use of global state; prefer local state to global where possible, or consider using public getters and setters on local state
-- Comment explaining why this needs to be global: "This is exposed globally because..."
-- Always initialize state to a default value at the time of declaration
globalState = {}

--------------------------------
------     LOCAL STATE    ------
--------------------------------
-- Always initialize state to a default value at the time of declaration
-- Always annotate the type of local state
local localState: {number} = {0}
local localTimer: Timer = nil

--------------------------------
------  LOCAL FUNCTIONS   ------
--------------------------------
-- Only use helper functions to de-duplicate logic; prefer fewer, deeper functions over many, shallow functions
-- These should be declared with `local function` and use camelCase
-- Each argument should have a type annotation, and the return type should be annotated if there is one
local function helperFunction(arg1: number, arg2: Player): boolean
    -- always prefer early returns to reduce nesting
    if arg1 < 0 then
        return false
    end
    if arg2.isLocal then
        return false
    end
    local _tempVar = 0  -- use `local _NAME` for variables declared in function scope
    -- implementation
    return true
end

--------------------------------
------  PUBLIC FUNCTIONS  ------
--------------------------------
-- Prefer private helper functions over public functions where possible
-- These should be declared with `function` and use PascalCase
-- Each argument should have a type annotation, and the return type should be annotated if there is one
function PublicFunction(arg1: Player, arg2: boolean): number
    -- always prefer early returns to reduce nesting
    -- global functions should always validate that inputs are non-nil before using them
    if not arg1 then
        print("ERROR: No player provided to PublicFunction")
        return -1
    end
    local _tempVar = 0  -- use `local _NAME` for variables declared in function scope
    -- implementation
    return 0
end

--------------------------------
------  TYPE DEFINITIONS  ------
--------------------------------
-- Exported types should be declared with `export type` and use PascalCase
export type MyType = {
    field: string
}

--------------------------------
------   CLASS METHODS    ------
--------------------------------
-- Follow this pattern for creating new class definitions
MyType = {}
MyType.__index = MyType

-- Constructors should be static `new()` functions that return a new instance of the class
function MyType.new(): MyType
    local self = setmetatable({}, MyType)
    -- initialize the new instance
    return self
end

-- Class methods should be declared with `function`, colon syntax, and use PascalCase
function MyType:Method1()
    -- implementation
end

--------------------------------
------  LIFECYCLE HOOKS   ------
--------------------------------
-- In scripts that are only client or server, use the lifecycle hooks with no prefix. For example:
function self:Start()
end

function self:Update()
    -- DO NOT use Update for things that occur after a duration; use a Timer instead.
    -- if you are doing something every frame, scale by Time.deltaTime for smoothness
    myVar = myVar + CONSTANT * Time.deltaTime
end

-- In client + server or module scripts, use the Client* or Server* lifecycle hooks instead. For example:
function self:ClientStart()
end

function self:ClientUpdate()
    -- DO NOT use Update for things that occur after a duration; use a Timer instead.
    -- if you are doing something every frame, scale by Time.deltaTime for smoothness
    myVar = myVar + CONSTANT * Time.deltaTime
end

function self:ServerStart()
end

function self:ServerUpdate()
    -- DO NOT use Update for things that occur after a duration; use a Timer instead.
    -- if you are doing something every frame, scale by Time.deltaTime for smoothness
    myVar = myVar + CONSTANT * Time.deltaTime
end