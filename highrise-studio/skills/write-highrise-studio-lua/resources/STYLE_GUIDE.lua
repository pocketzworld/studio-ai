--!Type(...)

--------------------------------
------ SERIALIZED FIELDS  ------
--------------------------------
-- SerializeField allows the value to be adjusted in the editor
-- SerializeField variables must have a type annotation
--!SerializeField
local prefabObject: GameObject = nil

--------------------------------
------     NETWORKING     ------
--------------------------------
-- Include all networked values and events here
-- Events used only in this script should be declared with `local`, use camelCase, and end in `Request`, `Event`, or `Response`
local myEvent = Event.new("MyEvent")

-- Events exposed globally should use PascalCase, and end in `Request`, `Event`, or `Response`
MyPublicEvent = Event.new("MyPublicEvent")

-- Networked values used only in this script should be declared with `local`, use camelCase, and end in `Value`
local myNetworkedIntValue = IntValue.new("MyNetworkedIntValue")

-- Networked values exposed globally should use PascalCase, and end in `Value`
MyPublicNetworkedIntValue = IntValue.new("MyPublicNetworkedIntValue")

--------------------------------
------  REQUIRED MODULES  ------
--------------------------------
local playerTracker = require("PlayerTracker")
local monsterLibrary = require("MonsterLibrary")

--------------------------------
------    GLOBAL STATE    ------
--------------------------------
-- Minimize the use of global state; prefer local state to global where possible
-- If state must be accessible, consider using public getters and setters to make it clear how it should be accessed
-- Comment explaining why this needs to be global: "This is exposed globally because..."
-- Always initialize state to a default value
globalState = {}

--------------------------------
------     LOCAL STATE    ------
--------------------------------
-- Always initialize state to a default value at the time of declaration
local localState = {}

--------------------------------
------  TYPE DEFINITIONS  ------
--------------------------------
-- Exported types should be declared with `export type` and use PascalCase
export type MyType = {
    field: string
}

--------------------------------
------     CONSTANTS      ------
--------------------------------
-- Use SCREAMING_SNAKE_CASE for constants
-- Never use magic numbers; always use a constant
local MAX_LEVEL = 20

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
------   CLASS METHODS    ------
--------------------------------
MyType = {}

-- Class methods should be declared with `function`, colon syntax, and use PascalCase
function MyType:Method1()
    -- implementation
end

--------------------------------
------  LIFECYCLE HOOKS   ------
--------------------------------
-- In client + server or module scripts, use the Client* or Server* lifecycle hooks
function self:ClientAwake()
end

function self:ClientStart()
end

function self:ServerAwake()
end

function self:ServerStart()
end
