--!Type(ScriptableObject)

--------------------------------
------  SERIALIZED FIELDS ------
--------------------------------

--!SerializeField
local outfits: { CharacterOutfit } = nil
--!SerializeField
local outfitStrings: { string } = nil
--!SerializeField
local outfits2: { CharacterOutfit } = nil
--!SerializeField
local outfits3: { CharacterOutfit } = nil
--!SerializeField
local removedOutfitPieces: { string } = nil
--!SerializeField
local outfitTransformation: OutfitRandomizerTemplate = nil
--!SerializeField
local fxPrefab: { GameObject } = nil
--!SerializeField
local avatarSize: number = 1
--!SerializeField
local moveSpeedModifier: number = 1
--!SerializeField
local tapToMoveSpeedModifier: number = 1
--!SerializeField
local duration: number = 3600
--!SerializeField
local animation: CharacterAnimation = nil
--!SerializeField
local animationRepeatTime: number = 120
--!SerializeField
local grantedPet: OutfitRandomizerTemplate = nil
--!SerializeField
local runEmotes: { string } = nil
--!SerializeField
local walkEmotes: { string } = nil

--------------------------------
------  PUBLIC FUNCTIONS  ------
--------------------------------

function GetRandomOutfitsToAssign(seed: number): { CharacterOutfit }
    if not seed then
        print("ERROR: No seed provided to GetRandomOutfitsToAssign")
        return {}
    end

    math.randomseed(seed)
    local _outfits = {}

    if outfits and #outfits > 0 then
        table.insert(_outfits, outfits[math.random(1, #outfits)])
    end
    if outfits2 and #outfits2 > 0 then
        table.insert(_outfits, outfits2[math.random(1, #outfits2)])
    end
    if outfits3 and #outfits3 > 0 then
        table.insert(_outfits, outfits3[math.random(1, #outfits3)])
    end

    return _outfits
end

function GetRandomOutfitStringToAssign(seed: number): CharacterOutfit
    if not seed then
        print("ERROR: No seed provided to GetRandomOutfitStringToAssign")
        return nil
    end

    math.randomseed(seed)
    local _outfitString = ""

    if outfitStrings and #outfitStrings > 0 then
        _outfitString = outfitStrings[math.random(1, #outfitStrings)]
    end

    if _outfitString == "" then
        return nil
    end

    local _outfit = CharacterOutfit.CreateInstance({
        _outfitString,
    }, nil)

    return _outfit
end

function GetRemovedOutfitPieces(): { string }
    return removedOutfitPieces
end

function GetOutfitTransformation(): OutfitRandomizerTemplate
    return outfitTransformation
end

function GetRandomFXPrefab(): GameObject
    if fxPrefab and #fxPrefab > 0 then
        return fxPrefab[math.random(1, #fxPrefab)]
    end
    return nil
end

function GetAvatarSize(): number
    return avatarSize
end

function GetDuration(): number
    return duration
end

function HasAnimation(): boolean
    return animation ~= nil
end

function GetAnimation(): CharacterAnimation
    return animation
end

function GetMoveSpeedModifier(): number
    return moveSpeedModifier
end

function GetTapToMoveSpeedModifier(): number
    return tapToMoveSpeedModifier
end

function GetAnimationRepeatTime(): number
    return animationRepeatTime
end

function GetGrantedPetRandomizer(): OutfitRandomizerTemplate
    return grantedPet
end

function GetRandomRunEmote(seed: number): string | nil
    if not runEmotes or #runEmotes == 0 then
        return nil
    end
    if not seed then
        print("ERROR: No seed provided to GetRandomRunEmote")
        return nil
    end
    math.randomseed(seed)
    return runEmotes[math.random(1, #runEmotes)]
end

function GetWalkEmote(seed: number): string | nil
    if not walkEmotes or #walkEmotes == 0 then
        return nil
    end
    if not seed then
        print("ERROR: No seed provided to GetWalkEmote")
        return nil
    end
    math.randomseed(seed)
    return walkEmotes[math.random(1, #walkEmotes)]
end
