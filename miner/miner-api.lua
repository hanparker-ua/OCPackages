local component = require("component")
local robot = component.robot
local geolyzer = component.geolyzer
local sides = require("sides")
local blocks = require("miner-blocks")

local api = {}

-- Error logging function
local function logError(message)
    local file = io.open("/home/mining_error.log", "a")
    if file then
        file:write(message .. "\n")
        file:close()
    end
end

-- Utility: Safe robot action with error logging
local function safeRobotAction(action, ...)
    local success, result = pcall(action, ...)
    if not success then
        logError("Robot action failed: " .. tostring(result))
    end
    return success, result
end

-- Movement functions
local function moveForward()
    return safeRobotAction(robot.forward)
end

local function moveUp()
    return safeRobotAction(robot.up)
end

local function moveDown()
    return safeRobotAction(robot.down)
end

local function turnLeft()
    return safeRobotAction(robot.turnLeft)
end

local function turnRight()
    return safeRobotAction(robot.turnRight)
end

-- Mining functions
local function mineFront()
    return safeRobotAction(robot.swing)
end

local function mineUp()
    return safeRobotAction(robot.swingUp)
end

local function mineDown()
    return safeRobotAction(robot.swingDown)
end

-- Check if inventory is full
local function isInventoryFull()
    for i = 1, robot.inventorySize() do
        if robot.count(i) == 0 then
            return false
        end
    end
    return true
end

-- Get block info at a specific side
local function getBlockInfo(side)
    local success, result = pcall(geolyzer.analyze, side)
    if success then
        return result
    else
        logError("Failed to analyze block: " .. tostring(result))
        return nil
    end
end

-- Convert geolyzer scan coordinates to world positions
local function scanAreaToPositions(offsetX, offsetZ, offsetY, width, depth, height, scanData)
    local positions = {}
    local index = 1

    for y = 0, height - 1 do
        for z = 0, depth - 1 do
            for x = 0, width - 1 do
                if index <= #scanData then
                    local worldX = offsetX + x
                    local worldY = offsetY + y
                    local worldZ = offsetZ + z
                    local hardness = scanData[index]

                    table.insert(positions, {
                        x = worldX,
                        y = worldY,
                        z = worldZ,
                        hardness = hardness
                    })
                end
                index = index + 1
            end
        end
    end

    return positions
end

-- Scan area for navigation (solid blocks vs air)
function api.scanForNavigation()
    local success, scanData = pcall(geolyzer.scan, -2, -2, -2, 4, 4, 4)
    if not success then
        logError("Geolyzer scan failed: " .. tostring(scanData))
        return { success = false, error = "Geolyzer scan failed" }
    end

    local positions = scanAreaToPositions(-2, -2, -2, 4, 4, 4, scanData)
    local solidBlocks = {}
    local airBlocks = {}

    for _, pos in ipairs(positions) do
        if pos.hardness > 0 then
            table.insert(solidBlocks, pos)
        else
            table.insert(airBlocks, pos)
        end
    end

    return {
        success = true,
        solidBlocks = solidBlocks,
        airBlocks = airBlocks
    }
end

-- Check if a block matches target using geolyzer analysis
local function isTargetBlock(side, blockName)
    local blockData = getBlockInfo(side)
    local block = blocks.getBlockByName(blockName)
    if blockData and blockData.name and block then
        return blockData.name == block.name
    end
    return false
end

-- Try to mine a block at a given side if it matches the target
local function tryMineTarget(side, blockName)
    if isTargetBlock(side, blockName) then
        if side == sides.front then
            return mineFront()
        elseif side == sides.top then
            return mineUp()
        elseif side == sides.bottom then
            return mineDown()
        end
    end
    return false
end

-- Try to move in a direction if the way is clear (no mining)
local function tryMove(side)
    local detected, description = robot.detect(side)
    if not detected or description == "air" or description == "passable" then
        if side == sides.front then
            return moveForward()
        elseif side == sides.top then
            return moveUp()
        elseif side == sides.bottom then
            return moveDown()
        end
    end
    return false
end

-- Mine blocks using hybrid approach: geolyzer for navigation, direct inspection for target identification
function api.start(blockName)
    local minedCount = 0
    local moveCount = 0
    local maxMoves = 100

    while moveCount < maxMoves do
        if isInventoryFull() then
            return {
                success = true,
                reason = "Inventory full",
                minedCount = minedCount
            }
        end

        local foundTarget = false

        -- Try mining target blocks in all directions
        if tryMineTarget(sides.front, blockName) then
            minedCount = minedCount + 1
            foundTarget = true
        end
        if tryMineTarget(sides.bottom, blockName) then
            minedCount = minedCount + 1
            foundTarget = true
        end
        if tryMineTarget(sides.top, blockName) then
            minedCount = minedCount + 1
            foundTarget = true
        end

        -- If no target found, try to move (no mining for movement)
        if not foundTarget then
            local scanResult = api.scanForNavigation()
            if scanResult.success then
                local moved = false

                -- Try to move forward
                if tryMove(sides.front) then
                    moved = true
                end

                -- Try turning and moving if forward fails
                if not moved then
                    turnRight()
                    if tryMove(sides.front) then
                        moved = true
                    else
                        -- Restore orientation
                        turnLeft()
                    end
                end

                -- Try vertical movement if horizontal failed
                if not moved then
                    if tryMove(sides.top) then
                        moved = true
                    elseif tryMove(sides.bottom) then
                        moved = true
                    end
                end

                if not moved then
                    -- Can't move anywhere
                    break
                end

                moveCount = moveCount + 1
            else
                logError("Navigation scan failed: " .. tostring(scanResult.error))
                break
            end
        end
    end

    return {
        success = moveCount < maxMoves,
        reason = moveCount >= maxMoves and "Max moves reached" or "Exploration completed",
        minedCount = minedCount
    }
end

-- Check inventory status
function api.getInventoryStatus()
    local totalSlots = robot.inventorySize()
    local usedSlots = 0
    local totalItems = 0

    for i = 1, totalSlots do
        local count = robot.count(i)
        if count > 0 then
            usedSlots = usedSlots + 1
            totalItems = totalItems + count
        end
    end

    return {
        totalSlots = totalSlots,
        usedSlots = usedSlots,
        freeSlots = totalSlots - usedSlots,
        totalItems = totalItems,
        isFull = usedSlots == totalSlots
    }
end

return api
