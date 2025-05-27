-- Miner CLI for OpenComputers
-- Command-line interface for the mining bot

local shell = require("shell")
local component = require("component")
local blocks = require("miner-blocks")
local minerAPI = require("miner-api")

-- Check if we have required components
local function checkComponents()
    if not component.isAvailable("robot") then
        print("ERROR: Robot component not found")
        return false
    end

    if not component.isAvailable("geolyzer") then
        print("ERROR: Geolyzer component not found")
        return false
    end

    return true
end

-- Log error to file
local function logError(message)
    local file = io.open("/home/mining_error.log", "a")
    if file then
        file:write(message .. "\n")
        file:close()
    end
end

-- Print usage information
local function printUsage()
    print("Usage:")
    print("  miner <block-name> --start  - Start mining target blocks")
    print("")
    print("Available blocks:")
    for shortName, blockInfo in pairs(blocks.getAllBlocks()) do
        print("  " .. shortName .. " - " .. blockInfo.description)
    end
end

-- Main function
local function main(...)
    local args, options = shell.parse(...)

    -- Check for help
    if options.h or options.help or #args == 0 then
        printUsage()
        return
    end

    -- Check components
    if not checkComponents() then
        return
    end

    -- Get block name
    local blockName = args[1]
    if not blockName then
        print("ERROR: Block name required")
        printUsage()
        return
    end

    -- Validate block name
    local blockInfo = blocks.getBlockByName(blockName)
    if not blockInfo then
        print("ERROR: Unknown block type: " .. blockName)
        print("Available blocks:")
        for shortName, info in pairs(blocks) do
            print("  " .. shortName .. " - " .. info.description)
        end
        return
    end

    print("Starting to mine " .. blockInfo.description .. "...")
    print("Target: " .. blockInfo.name)
    print("Press Ctrl+Alt+C to stop the bot")

    local result = minerAPI.start(blockName)
    if not result.success then
        local errorMsg = "Mining failed: " .. tostring(result.error)
        print("ERROR: " .. errorMsg)
        logError(errorMsg)
        return
    end

    print("Mining completed!")
    print("Reason: " .. (result.reason or "Unknown"))
    print("Blocks mined: " .. (result.minedCount or 0))

    -- Show inventory status
    local invStatus = minerAPI.getInventoryStatus()
    if invStatus then
        print("Inventory: " .. invStatus.usedSlots .. "/" .. invStatus.totalSlots .. " slots used")
        if invStatus.isFull then
            print("WARNING: Inventory is full!")
        end
    end
end

-- Run with error handling
local success, error = pcall(main, ...)
if not success then
    local errorMsg = "CLI error: " .. tostring(error)
    print("ERROR: " .. errorMsg)
    logError(errorMsg)
end
