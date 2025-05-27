# 📡 Geolyzer API Reference

The **Geolyzer** component is provided by the geolyzer block in OpenComputers.

- **Component name:** `geolyzer`

---

## 🛠️ Methods

### `scan(x: number, z: number[, y: number, w: number, d: number, h: number][, ignoreReplaceable: boolean | options: table]): table`

Analyzes the density (hardness) of an area at the specified relative coordinates.

- **Parameters:**
  | Name                | Type     | Description                                                                 |
  |---------------------|----------|-----------------------------------------------------------------------------|
  | x                   | number   | X offset from geolyzer                                                      |
  | z                   | number   | Z offset from geolyzer                                                      |
  | y                   | number   | Y offset from geolyzer (optional, default: 0)                               |
  | w                   | number   | Width (blocks in +X, optional, default: 1)                                  |
  | d                   | number   | Depth (blocks in +Z, optional, default: 1)                                  |
  | h                   | number   | Height (blocks in +Y, optional, default: 1)                                 |
  | ignoreReplaceable   | boolean  | Ignore replaceable blocks (optional)                                        |
  | options             | table    | Options table (optional, alternative to ignoreReplaceable)                  |

- **Returns:**
  A linear table of hardness values for the scanned area.

- **Notes:**
  - The scan area starts at the offset `(x, z, y)` and extends by `(w, d, h)` blocks.
  - The result is a linear table. Values go first in +X, then +Z, then +Y.
  - The number of values returned is always 64. Ignore extra values if your scan volume is smaller.
  - Hardness values are noisier the further they are from the geolyzer. The exact formula for calculating how much a single value can deviate from the real hardness value of a specific block is: euclidean distance to block * 1/33 * geolyzerNoise where geolyzerNoise is a mod config option with a default value of 2.
  - The offset is **absolute** (not affected by robot facing).

---

### `analyze(side: number[, options: table]): table`

Gets information about a directly adjacent block.

- **Parameters:**
  | Name    | Type     | Description                                 |
  |---------|----------|---------------------------------------------|
  | side    | number   | Side to analyze (relative to geolyzer)      |
  | options | table    | Optional options table                      |

- **Returns:**
  Table with block info:
  - `name` (e.g. `minecraft:dirt`)
  - `metadata`
  - `hardness`
  - ...and more

- **Notes:**
  - Consumes the same energy as `scan`.
  - Can be disabled via config (`misc.allowItemStackInspection`).

---

### `store(side: number, dbAddress: string, dbSlot: number): boolean`

Stores an item stack representation of the block on the specified side into a database component.

- **Parameters:**
  | Name      | Type     | Description                                 |
  |-----------|----------|---------------------------------------------|
  | side      | number   | Side to analyze                             |
  | dbAddress | string   | Address of the database component           |
  | dbSlot    | number   | Slot in the database                        |

- **Returns:**
  `true` on success, `false` otherwise.

- **Notes:**
  May not work for all blocks, especially those with NBT data.

---

### `detect(side: number): boolean, string`

Detects the block on the given side.

- **Parameters:**
  | Name | Type   | Description                        |
  |------|--------|------------------------------------|
  | side | number | Side to detect                     |

- **Returns:**
  - `boolean`: `true` if movement is blocked, `false` otherwise
  - `string`: General description (`entity`, `solid`, `replaceable`, `liquid`, `passable`, `air`)

---

### `canSeeSky(): boolean`

Returns `true` if there is a clear line of sight to the sky directly above.

---

### `isSunVisible(): boolean`

Returns `true` if the sun is currently visible directly above (not blocked and it's daytime).

---

## 🧑‍💻 Example: Scanning a 3D Area

```lua
local component = require("component")
local geolyzer = component.geolyzer

local offsetx, offsetz, offsety = 4, -3, -5
local sizex, sizez, sizey = 3, 4, 5

local map = {}
local scanData = geolyzer.scan(offsetx, offsetz, offsety, sizex, sizez, sizey)
local i = 1
for y = 0, sizey - 1 do
  for z = 0, sizez - 1 do
    for x = 0, sizex - 1 do
      map[i] = {
        posx = offsetx + x,
        posy = offsety + y,
        posz = offsetz + z,
        hardness = scanData[i]
      }
      i = i + 1
    end
  end
end

for i = 1, sizex * sizez * sizey do
  print(map[i].posx, map[i].posy, map[i].posz, map[i].hardness)
end
```

---

## ℹ️ Additional Notes

- All coordinates are **relative to the geolyzer**.
- For more details, see the [OpenComputers documentation](https://ocdoc.cil.li/component:geolyzer).
