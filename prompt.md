## 📝 AI Coding Prompt: Minimalist Mining Bot for OpenComputers

**Goal:**
Create a mining bot for OpenComputers (Minecraft mod) that mines only a specified target block (by short name), uses the geolyzer for smart detection, mines in a logical line-by-line pattern, and stops if its inventory is full.

- **All errors must be handled and logged to `/home/mining_error.log` (simple format).**
- **No test files.**

---

### **Repository and Installation Structure**

- In the **package repository**, both files are located in the `miner` directory:
    - `miner/miner.lua`
    - `miner/miner-api.lua`
- When the package is installed, files are placed as:
    - `/bin/miner.lua` (from `miner/miner.lua`)
    - `/usr/lib/miner-api.lua` (from `miner/miner-api.lua`)

---

### **Functional Requirements**

- **Target Block Only:**
  The bot must mine only blocks matching the specified block name (no metadata).

- **Short Name Dictionary:**
  The CLI accepts short names for blocks (e.g., `lignite-stone`), mapped to full block names via an internal dictionary.
  Only the short name for lignite ore needs to be supported in the first version (see README.md for mapping).

- **Hybrid Block Detection:**
  Use the geolyzer to scan for solid blocks vs air for navigation and area assessment.
  Use direct inspection (`robot.inspect()`) to identify target blocks by name.
  - The geolyzer scan is capped at 64 blocks per scan (e.g., 4×4×4 area).

- **Logical Mining Pattern:**
  The bot should mine in a line-by-line, layer-by-layer pattern (not random).

- **Exploration:**
  If no target block is found in the current scan range, the bot should move forward (or in another direction) to explore new locations and repeat the scan/mining logic.

- **Stop on Full Inventory:**
  The bot must check its inventory and stop mining if full (stop in place).

- **Reachability:**
  Only mine target blocks that can be reached via air blocks. If a path to a target block is blocked, ignore it and continue.

- **CLI Usage Only:**
  - `miner <short-block-name> --start`
    Start the bot to mine all matching blocks using hybrid detection approach.

- **Error Handling:**
  - All errors must be caught and logged to `/home/mining_error.log` (simple format, no timestamp required).
  - User-facing errors should be clear and actionable.

---

### **File 1: `/bin/miner.lua`**
*(In repo: `miner/miner.lua`)*

- Parse command-line arguments.
- Validate user input.
- Map short block names to full block names.
- Call the miner API as needed.
- Print user-friendly messages and errors.
- Log all errors to `/home/mining_error.log`.

### **File 2: `/usr/lib/miner-api.lua`**
*(In repo: `miner/miner-api.lua`)*

- Provide functions for:
  - Scanning area for solid blocks vs air (navigation).
  - Direct inspection of adjacent blocks for target identification.
  - Mining blocks in a logical pattern.
  - Checking inventory status.
  - Handling robot movement and mining.
- All robot/geolyzer logic should be here.
- Only mine reachable target blocks (by air path).
- Return clear status and error messages to the CLI.

---

### **General Notes**

- Use idiomatic Lua and OpenComputers best practices.
- No test files or extra scripts.
- No external dependencies beyond standard OpenComputers APIs.
- All errors must be logged to `/home/mining_error.log`.
