## **Prompt for AI Agent: OpenComputers Mining Robot Logic (Revised with geolyzer.scan Limit)**

---

**Context:**
I am developing a mining robot program for the OpenComputers mod in Minecraft (Lua). The robot is equipped with a geolyzer and should be able to explore, map, and mine blocks efficiently. The robot's starting position is (0, 0, 0), and it should keep track of its position and orientation as it moves.

---

**Relevant API Reference:**

- `geolyzer.analyze(side)`
  Analyzes the block adjacent to the given side, returning detailed information such as block name, metadata, and hardness.

- `geolyzer.scan(x, z[, y, w, d, h][, ignoreReplaceable|options])`
  Scans a 3D area at relative coordinates and returns a linear table of block hardness values.
  **Important:** The total number of blocks scanned per call (w × d × h) must not exceed 64, or the method will throw an error.
  This method is useful for detecting solid vs. air blocks, but does **not** provide block names or metadata.

- `robot.detect([side])`
  Detects what is directly in front (or at the given side) of the robot and returns whether the robot could move through it, as well as a generic description (entity, solid, replaceable, liquid, passable, or air).

---

**Requirements:**

1. **Block Detection and Analysis:**
    - For each adjacent side (front, back, left, right, top, bottom), use `robot.detect(side)` to determine if the block is air, passable, or solid.
    - Use `geolyzer.analyze(side)` on each adjacent block to obtain its name, metadata, and hardness.

2. **Mapping:**
    - Store information about each analyzed block in a map data structure, keyed by world coordinates relative to the starting position (0, 0, 0).
    - For each position, store:
        - Block type (air, passable, solid, etc.)
        - Geolyzer data (name, metadata, hardness, etc.)
        - How many times the robot has visited this position

3. **Target Search:**
    - Search the map for all blocks matching a target block name.
    - If found, sort them by distance from the robot and select the nearest one as the goal.

4. **Pathfinding:**
    - If a goal is found, use the map to build a path to it.
    - The path should only go through air or passable blocks (as determined by the map).
    - The pathfinding algorithm can be simple (BFS or DFS), as the map is built incrementally.

5. **Exploration:**
    - If no target block is found, find the nearest unexplored or passable block and move to it.
    - Only make one movement per exploration step, then repeat the process.

6. **Mining:**
    - If the robot is adjacent to any mineable blocks (front, top-front, bottom-front), mine them all before moving.

7. **Loop:**
    - Repeat the process: detect, analyze, map, search, pathfind/explore, mine, and move.

---

**Additional Notes:**

- The robot should avoid revisiting the same position unnecessarily (use visit counts).
- The robot should update its map and position/orientation after every move or mining action.
- The robot should be robust to obstacles and dead ends.
- Inventory and energy management are not the focus for now.
- **When using `geolyzer.scan`, ensure that the total number of blocks scanned in a single call does not exceed 64, or the method will throw an error.**

---

**Task:**

- Design and implement the movement, mapping, and mining logic for this robot, following the requirements above.
- Use clear, modular Lua code suitable for OpenComputers.
- Start by designing the map data structure and the functions for block detection and analysis.
- Then, implement the main loop and the logic for searching, pathfinding, exploration, and mining.
- Add comments and explanations as needed.
