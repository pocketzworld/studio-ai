--!Type(Module)

--------------------------------
------  TYPE DEFINITIONS  ------
--------------------------------

export type SimpleOutfit = {
    clothingList: { ClothingData },
}

export type ClothingData = {
    id: string,
    color: number,
}

--------------------------------
------  PUBLIC FUNCTIONS  ------
--------------------------------

function SerializeOutfitToData(outfit: CharacterOutfit): SimpleOutfit
    if not outfit then
        print("ERROR: No outfit provided to SerializeOutfitToData")
        return nil
    end

    local _clothingList = {}
    for _, clothing in ipairs(outfit.clothing) do
        table.insert(_clothingList, {
            id = clothing.id,
            color = clothing.color
        })
    end
    return { clothingList = _clothingList }
end

function SerializeIdListToSimpleOutfit(outfitIds: { string }): SimpleOutfit
    if not outfitIds then
        print("ERROR: No outfit IDs provided to SerializeIdListToSimpleOutfit")
        return nil
    end

    local _simpleOutfit: SimpleOutfit = {
        clothingList = {},
    }
    for _, id in ipairs(outfitIds) do
        table.insert(_simpleOutfit.clothingList, { id = id, color = 0 })
    end
    return _simpleOutfit
end

function DeserializeIdListToOutfit(outfitIds: { string }, skeletonId: string | nil): CharacterOutfit
    if not outfitIds then
        print("ERROR: No outfit IDs provided to DeserializeIdListToOutfit")
        return nil
    end

    return CharacterOutfit.CreateInstance(outfitIds, skeletonId)
end

function DeserializeClothingDataToOutfit(simpleOutfit: SimpleOutfit, skeletonId: string | nil): CharacterOutfit
    if simpleOutfit == nil then
        print("ERROR: No outfit provided to DeserializeClothingDataToOutfit")
        return nil
    end

    local _outfitIds = {}
    for _, clothingData in ipairs(simpleOutfit.clothingList) do
        table.insert(_outfitIds, clothingData.id)
    end

    local _outfit = DeserializeIdListToOutfit(_outfitIds, skeletonId)

    for i = 1, #_outfit.clothing do
        _outfit.clothing[i].color = simpleOutfit.clothingList[i].color
    end

    return _outfit
end

function DeserializeSimpleOutfitToOutfit(simpleOutfit: SimpleOutfit): CharacterOutfit
    if simpleOutfit == nil then
        print("ERROR: No outfit provided to DeserializeSimpleOutfitToOutfit")
        return nil
    end

    local _outfitIds = {}
    for _, clothingData in ipairs(simpleOutfit.clothingList) do
        table.insert(_outfitIds, clothingData.id)
    end

    local _outfit = DeserializeIdListToOutfit(_outfitIds)

    for i = 1, #_outfit.clothing do
        _outfit.clothing[i].color = simpleOutfit.clothingList[i].color
    end

    return _outfit
end
