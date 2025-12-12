--!Type(UI)

-- Not all sections are required for all scripts. Only include sections that have something in them. You can remove all of the guidance comments.

--------------------------------
------ SERIALIZED FIELDS  ------
--------------------------------
-- SerializeField allows the value to be adjusted in the editor
-- SerializeField variables must have a type annotation
--!SerializeField
local prefabObject: GameObject = nil

--------------------------------
------  USS CLASS NAMES   ------
--------------------------------
-- Use a variable to refer to any needed USS class names
-- Style dynamically created elements with `AddToClassList()` to apply USS rules

-- Translate the kebab-case class name to PascalCase and suffix it with "Class"
local LeaderboardTitleClass = "leaderboard-title"

--------------------------------
---- UXML ELEMENT BINDINGS -----
--------------------------------
-- Each named element in the UXML file must be bound here if you want to interact with it in your script
-- Bindings must be annotated with the element type and initialized to nil
-- Match the UXML name exactly, including the underscore prefix

--!Bind
local _leaderboardTitle: Label = nil
--!Bind
local _leaderboardContainer: UIScrollView = nil  -- Don't include the "hr:" prefix in the Lua type annotation

--------------------------------
------     CONSTANTS      ------
--------------------------------
-- Use SCREAMING_SNAKE_CASE for constants
-- Never use magic numbers; always use a constant
local MAX_LEVEL = 20

--------------------------------
------  REQUIRED MODULES  ------
--------------------------------
local playerTracker = require("PlayerTracker")
local monsterLibrary = require("MonsterLibrary")

--------------------------------
------     LOCAL STATE    ------
--------------------------------
-- Always initialize state to a default value at the time of declaration
-- Always annotate the type of local state
-- If the state is never going to change, use a constant (in the earlier section) instead
local localState: {number} = {0}

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
------  LIFECYCLE HOOKS   ------
--------------------------------
-- Include any behavior lifecycle hooks that the script needs. Do not include the Client* prefix, as UI is already client-only. For example:
function self:Awake()
end

function self:Start()
end

