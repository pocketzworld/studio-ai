--!Type(Module)

--------------------------------
------  REQUIRED MODULES  ------
--------------------------------

local OutfitUtils = require("OutfitUtils")
local UIManager = require("UIManager")
local SaveManager = require("SaveManager")
local Utils = require("Utils")

--------------------------------
------  SERIALIZED FIELDS ------
--------------------------------

--!SerializeField
local gameSettings: GameSettings = nil
--!SerializeField
local mainCamera: Camera = nil
--!SerializeField
local musicRotator: MusicRotator = nil

--------------------------------
------     NETWORKING     ------
--------------------------------

SaveDataLoadedEvent = Event.new("SaveDataLoadedEvent")

--------------------------------
------     LOCAL STATE    ------
--------------------------------

local allPlayers: { CharacterModel } = {}

--------------------------------
------  LOCAL FUNCTIONS   ------
--------------------------------

local function showWelcomePopup()
    local _ui: UIWelcomePopup = UIManager.OpenWelcomePopupUI()
    if not _ui then
        UIManager.OpenGameHUDUI()
        return
    end
    _ui.Init(function()
        UIManager.OpenGameHUDUI()
    end)
end

local function onPlayerDataLoaded(playerData: PlayerData)
    SaveDataLoadedEvent:Fire()

    if not playerData.SeenIntro then
        showWelcomePopup()
        playerData.SeenIntro = true
        SaveManager.ClientSeenIntro()
    else
        UIManager.OpenGameHUDUI()
    end
end

--------------------------------
------  PUBLIC FUNCTIONS  ------
--------------------------------

function GetCamera(): Camera
    return mainCamera
end

function GetGameSettings(): GameSettings
    return gameSettings
end

function IsSaveDataLoaded(): boolean
    return SaveManager.IsPlayerDataLoaded()
end

function SetMusicRotatorEnabled(enabled: boolean)
    if not enabled then
        print("ERROR: No enabled value provided to SetMusicRotatorEnabled")
        return
    end
    if musicRotator then
        musicRotator.SetEnabled(enabled)
    end
end

function GetAllPlayerModels(): { CharacterModel }
    return allPlayers
end

function AddModelToList(model: CharacterModel)
    if not model then
        print("ERROR: No model provided to AddModelToList")
        return
    end
    table.insert(allPlayers, model)
end

function RemoveModelFromList(model: CharacterModel)
    if not model then
        print("ERROR: No model provided to RemoveModelFromList")
        return
    end
    Utils.RemoveInTable(allPlayers, model)
end

function GetCharacterModelForPlayer(player: Player): CharacterModel | nil
    if not player then
        print("ERROR: No player provided to GetCharacterModelForPlayer")
        return nil
    end
    if Utils.IsPlayerNull(player) then
        return nil
    end
    for _, characterModel in ipairs(allPlayers) do
        if not Utils.IsModelValid(characterModel) then
            continue
        end
        local _modelPlayer = characterModel.GetPlayer()
        if Utils.IsPlayerNull(_modelPlayer) then
            return nil
        end
        if _modelPlayer.user.id == player.user.id then
            return characterModel
        end
    end
    return nil
end

function GetRandomPlayerFromList(ignoreLocal: boolean): CharacterModel
    local _validPlayers: { CharacterModel } = {}
    for _, model in ipairs(allPlayers) do
        if not Utils.IsModelValid(model) then
            continue
        end
        if not ignoreLocal or model.GetPlayer().user.id ~= client.localPlayer.user.id then
            table.insert(_validPlayers, model)
        end
    end

    if #_validPlayers == 0 then
        return nil
    end

    return _validPlayers[math.random(1, #_validPlayers)]
end

function GetRandomPlayerInRange(thisPlayer: Character, range: number): CharacterModel?
    if not thisPlayer then
        print("ERROR: No player provided to GetRandomPlayerInRange")
        return nil
    end

    local _validPlayers: { CharacterModel } = {}
    for _, player in ipairs(allPlayers) do
        if Utils.IsPlayerNull(player) then
            continue
        end

        if player.GetPlayer().user.id ~= thisPlayer.player.user.id
            and Utils.WithinRange(player.transform.position, thisPlayer.transform.position, range)
        then
            table.insert(_validPlayers, player)
        end
    end

    if #_validPlayers == 0 then
        return nil
    end

    return _validPlayers[math.random(1, #_validPlayers)]
end

function HideHUD()
    UIManager.ShowUI(UIManager.UINames.GameHUD, false)
end

function ClearData()
    SaveManager.ClearData()
end

--------------------------------
------  LIFECYCLE HOOKS   ------
--------------------------------

function self:ClientAwake()
    gameSettings.Validate()
    SaveManager.LoadPlayerData(onPlayerDataLoaded)
end
