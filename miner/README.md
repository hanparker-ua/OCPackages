# 🤖 Parker Mining Bot (OpenComputers)

A configurable mining bot library and command-line tool for OpenComputers robots.

---

## 🚀 Quick Start

```bash
oppm register hanparker-ua/OCPackages
oppm install miner
# miner <block-name>
miner lignite-stone
```

---

## 🧠 How It Works

The Mining Bot is designed to:

1. **Mine Only the Target Block:**
   The bot will exclusively mine blocks that match the specified target (by name). It will ignore all other blocks.

2. **Smart Block Detection:**
   The bot uses its geolyzer to scan the surrounding area and intelligently locate the target block before mining. It will not start mining until it has found a valid target.

3. **Logical Mining Pattern:**
   The bot mines in a logical, line-by-line pattern (not randomly), ensuring efficient and predictable excavation. This helps avoid unnecessary movement and missed blocks.

4. **Automatic Stop on Full Inventory:**
   The bot will automatically stop mining if its inventory becomes full, preventing item loss and allowing for safe unloading before resuming.

---

## 💎 Available Blocks

- **lignite-stone** — Lignite sedimentary stone from Underground Biomes

---

## 📄 Error Logs

Errors are logged to `/home/mining_error.log`

---

## 📖 Documentation

- [Geolyzer API Reference](docs/geolyzer-api.md)
- [Terminal Command Examples](docs/terminal-command-example.md)
