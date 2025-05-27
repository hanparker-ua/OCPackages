local api = {}

-- Block dictionary mapping short names to full block names
local BLOCKS = {
    ["lignite_stone"] = {
        name = "UndergroundBiomes:sedimentaryStone",
        description = "Lignite sedimentary stone from Underground Biomes"
    }
}

-- Get supported blocks
function api.getAllBlocks()
    return BLOCKS
end

function api.getBlockByName(name)
    return BLOCKS[name]
end

return api;
