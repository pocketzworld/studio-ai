# MagiMonsters Lua Style Guide

This document outlines the coding conventions and best practices for Highrise Studio Lua scripts.

## Contents
- Naming Conventions
- Code Organization
- Functions
- Variables
- Comments
- Error Handling
- Performance Best Practices

Quick checklist:
- [ ] Client/server separation is maintained
- [ ] Type annotations are present on function parameters
- [ ] Event connections are cleaned up on disconnect
- [ ] Timer callbacks check if systems are still active
- [ ] Variables use appropriate scope (local vs module)
- [ ] Public functions follow PascalCase naming
- [ ] Variables and local functions follow camelCase naming
- [ ] Complex logic has explanatory comments

---

## Naming Conventions

### Variables
- **Local variables**: `camelCase`
  ```lua
  local playerMonster = {}
  local currentBattleTurn = 0
  local actionLibrary = require("ActionLibrary")
  ```

- **Temporary variables**: Prefix with underscore `_camelCase`
  ```lua
  local _tempCollection = {}
  local _monsterStats = monster.stats
  local _lootTable = {}
  ```

- **Module-level state**: `camelCase`
  ```lua
  players = {}  -- Global module state
  currentBattleTurn = 0
  actionCooldowns = {}
  ```

- **SerializeField variables**: `camelCase` with type annotation
  ```lua
  --!SerializeField
  local battleScreenOBJ: GameObject = nil
  --!SerializeField
  local elementsIcons: {Texture} = nil
  ```

### Functions
- **Public functions**: `PascalCase`
  ```lua
  function GetDamageWithStats(action, attacker, defender)
  function StartBattleServer(player, enemy, enemyLevel)
  function CalculateMaxXPForLevel(level)
  ```

- **Private/local functions**: `camelCase` with `local function`
  ```lua
  local function calculateDamage()
  local function isValidTarget()
  ```

- **Class methods**: `PascalCase` with colon syntax
  ```lua
  function Battle:DoAction(actionID)
  function Battle:ProcessCooldowns(isPlayerTurn)
  function PVPBattle:EndBattle(winner)
  ```

### Events
- **Event names**: `PascalCase` ending in `Request`, `Event`, or `Response`
  ```lua
  StartBattleEvent = Event.new("StartBattleEvent")
  DoActionRequest = Event.new("DoActionRequest")
  VictoryResponse = Event.new("VictoryResponse")
  ```

### Types
- **Export types**: `PascalCase`
  ```lua
  export type MonsterData = {
      name: string,
      level: number,
      stats: {}
  }

  export type BattleObject = {
      player: Player,
      turn: number
  }
  ```

### Constants
- **Constants**: `SCREAMING_SNAKE_CASE`
  ```lua
  local CRIT_CHANCE = 1/16
  local CRIT_MULTIPLIER = 1.5
  local RAND_MIN, RAND_MAX = 0.85, 1.00
  ```

---

## Code Organization

### Module Structure
```lua
--!Type(Module)

-- 1. SerializeField declarations
--!SerializeField
local prefabObject: GameObject = nil

-- 2. Event declarations
local MyEvent = Event.new("MyEvent")

-- 3. Module requires
local playerTracker = require("PlayerTracker")
local monsterLibrary = require("MonsterLibrary")

-- 4. Module-level state
local moduleState = {}

-- 5. Type definitions
export type MyType = {
    field: string
}

-- 6. Constants
local MAX_LEVEL = 20

-- 7. Helper functions (private)
local function helperFunction()
end

-- 8. Public functions
function PublicFunction()
end

-- 9. Lifecycle hooks
function self:ClientAwake()
end

function self:ServerAwake()
end

function self:ClientStart()
end

function self:ServerStart()
end
```

### Client/Server Separation
Always clearly separate client and server code:

```lua
-----------------------
--    CLIENT SIDE    --
-----------------------

function ClientFunction()
    -- Client-only code
end

function self:ClientAwake()
    -- Client initialization
end

-----------------------
--    SERVER SIDE    --
-----------------------

function ServerFunction()
    -- Server-only code
end

function self:ServerAwake()
    -- Server initialization
end
```

---

## Functions

### Function Signatures
Always use type annotations for parameters:

```lua
function GivePlayerItem(player: Player, itemId: string, amount: number)
    -- implementation
end

function Battle:DoAction(actionID: string): boolean
    -- implementation
    return true
end
```

### Function Syntax
- Use early returns to reduce nesting

    **Good:**
    ```lua
    function Battle:DoAction(actionID: string)
        if self.isProcessingEffects then
            print("Action blocked")
            return false
        end

        if self.isEnded then
            return false
        end

        -- Main logic here
    end
    ```

    **Bad:**
    ```lua
    function Battle:DoAction(actionID: string)
        if not self.isProcessingEffects then
            if not self.isEnded then
                -- Deep nesting...
            end
        end
    end
    ```

- Only create helper functions to de-duplicate logic; create few deep functions over many small functions

    **Good:**
    ```lua
    -- Single action-related method that the owner of the Battle needs to call
    function Battle:DoAction(actionID: string)
        -- Pre-action logic
        -- ...

        -- Main logic
        -- ...

        -- Post-action logic
        -- ...
    end
    ```

    **Bad:**
    ```lua
    -- Unclear whether the owner of the Battle should call these directly vs only call DoAction()
    function Battle:DoPreAction(actionID: string)
        -- Pre-action logic
        -- ...
    end

    function Battle:DoPostAction(actionID: string)
        -- Post-action logic
        -- ...
    end

    function Battle:DoAction(actionID: string)
        self:DoPreAction(actionID)
        -- Main logic
        -- ...
        self:DoPostAction(actionID)
    end
    ```

---

## Variables

### Scope
- Prefer `local` variables whenever possible
- Only use module-level variables for state that needs to be shared
- Document why a variable is module-level with a comment
- Use getters / setters rather than exposed variables where possible

```lua
-- This variable needs to be exposed because...
playerNames = {}

-- Local variable, global accessors
local players = {}
function AddPlayer(player: Player)
    table.insert(players, player)
end

function RemovePlayer(player: Player)
    table.remove(players, player)
end

-- Local variable only needed in this function
local function processPlayer()
    local tempData = {}
end
```

### Initialization
Always initialize variables with default values:

```lua
-- Good
local currentTurn = 0
local monsterCollection = {}
local isActive = false

-- Bad
local currentTurn
local monsterCollection
```

---

## Comments

### When to Comment
- **Complex algorithms** (damage formulas, XP calculations)
- **Business logic** (drop rates, balance values)
- **Non-obvious behavior** (timer callbacks, race condition fixes)
- **TODOs** for incomplete features

### Comment Style
```lua
-- Single-line comments for brief explanations
local damage = baseDamage * modifier

-- Multi-line comments for complex explanations
--[[
    Pokémon-style damage calculation using Gen III+ formula.
    Factors in: level, base power, attack/defense stats, STAB, type effectiveness,
    critical hits, and random variance.
]]--
function GetDamageWithStats(...)
end

-- Section headers
-----------------------
--    CLIENT SIDE    --
-----------------------

-- TODO comments for future work
-- TODO: implement type effectiveness chart for all 13 elements
```

### Documentation Comments
Document public API functions:
```lua
----------------------------------------------------------------------
-- Calculate XP gained from defeating a monster
--  exp = floor( (a * BaseExpYield * L) / (5 * recipients) + 0.5 )
--  a = 1.5 if trainer-owned foe, else 1.0
--  L = defeated monster level
--  recipients = how many allies share the EXP
----------------------------------------------------------------------
function CalculateXPFromMonster(defeatedMonster, isTrainerMon, recipients)
    -- implementation
end
```

---

## Error Handling

### Validation
Always validate inputs before processing:

```lua
function GivePlayerItem(player: Player, itemId: string, amount: number)
    if not player then
        print("ERROR: Invalid player")
        return
    end

    local itemData = itemLibrary.GetItemByID(itemId)
    if not itemData then
        print("ERROR: Item not found:", itemId)
        return
    end

    -- Process the item
end
```

### Null Checks
Check for nil before accessing nested properties:

```lua
-- Good
if playerTracker.players[player] and playerTracker.players[player].monsterCollection then
    local collection = playerTracker.players[player].monsterCollection.value
end

-- Also good with early return
local playerInfo = playerTracker.players[player]
if not playerInfo then
    print("Player not tracked")
    return
end

local collection = playerInfo.monsterCollection.value
```

### Print Statements
Use descriptive print statements for debugging:

```lua
-- Good
print("Battle Victory:", player.name, "defeated", monster.speciesName)
print("ERROR: Player not found for ID:", playerID)

-- Bad
print("win")
print("error")
```

---

## Performance Best Practices

### Timer Usage
Always check if systems are still active before executing timer callbacks:

```lua
Timer.After(2, function()
    if self.isEnded then
        return  -- Battle ended, don't continue
    end

    -- Execute timer logic
end)
```

### Table Operations
```lua
-- Good: Pre-allocate table size if known
local items = {}
for i = 1, 100 do
    items[i] = createItem()
end

-- Avoid: Don't use table.insert in tight loops if you can use direct assignment
```

### Event Connections
Clean up event connections when objects are destroyed:

```lua
function self:ServerAwake()
    server.PlayerDisconnected:Connect(function(player)
        -- Clean up player-specific state
        playerBattles[player] = nil
        searchesByPlayer[player] = nil
    end)
end
```

---

## Magic Numbers

### Avoid Magic Numbers
Define constants for all game balance values:

```lua
-- Bad
if math.random(1, 100) <= 10 then
    -- Give egg
end

-- Good
local EGG_DROP_CHANCE = 0.10  -- 10% chance
if math.random() <= EGG_DROP_CHANCE then
    -- Give egg
end
```
