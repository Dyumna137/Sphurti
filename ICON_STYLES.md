# Icon Style Guide - Minimal Custom Icons

This document explains the unique minimal icon set used in this Neovim config.

---

## Philosophy

**What We AVOID:**
- ❌ Standard Nerd Font icons (everyone uses them)
- ❌ Emoji-style symbols (😀 🎉 - too casual)
- ❌ Common AI/LLM suggested icons (  - overused)
- ❌ Font dependencies (must work everywhere)

**What We USE:**
- ✓ Geometric Unicode characters (◇ △ ■)
- ✓ Mathematical symbols (⊕ ⊖ ⊙)
- ✓ Box drawing characters (┃ ║ │)
- ✓ Available in ALL standard fonts
- ✓ Technical and minimalist aesthetic
- ✓ Each symbol has logical meaning

---

## Current Icon Set

### Status Bar (Lualine)

**Separators:** `┃` (Box Vertical)
- Why: Technical/terminal aesthetic
- Looks: `┃ NORMAL ┃ main ┃ file.lua ┃`

**Diagnostics:**
- `■` (Filled Square) - **Error** - Solid/blocking issue
- `△` (Triangle) - **Warning** - Caution/attention needed
- `○` (Circle) - **Info** - Information/notice
- `◇` (Diamond) - **Hint** - Suggestion/tip

**Git Changes:**
- `⊕` (Circled Plus) - **Added** - Mathematical addition
- `⊙` (Circled Dot) - **Modified** - Center point changed
- `⊖` (Circled Minus) - **Removed** - Mathematical subtraction

**Example Status Bar:**
```
┃ NORMAL ┃ main ┃ init.lua ┃ ■2 △5 ┃ ⊕3 ⊙1 ⊖2 ┃ UTF-8 ┃ Lua ┃ 50% ┃
```

---

## Alternative Icon Sets

If you want to try different styles, here are the alternatives:

### Style 1: Mathematical/Academic
```lua
-- Separators: ∥ (parallel)
-- Error: ⊗ (circled X)
-- Warning: ⊘ (circled slash)
-- Added: ⊕ (circled plus)
-- Removed: ⊖ (circled minus)

-- Looks: ∥ NORMAL ∥ main ∥ ⊗2 ⊘5 ∥ ⊕3 ⊖1 ∥
```

### Style 2: Block Elements
```lua
-- Separators: ▐ (right half block)
-- Error: ▀ (upper half block)
-- Warning: ▄ (lower half block)
-- Added: ▲ (up triangle)
-- Removed: ▼ (down triangle)

-- Looks: ▐ NORMAL ▐ main ▐ ▀2 ▄5 ▐ ▲3 ▼1 ▐
```

### Style 3: Arrow Variants
```lua
-- Separators: │ (light vertical)
-- Error: ↯ (down zigzag)
-- Warning: ↯ (zigzag)
-- Added: ↑ (up arrow)
-- Removed: ↓ (down arrow)

-- Looks: │ NORMAL │ main │ ↯2 ⤫5 │ ↑3 ↓1 │
```

### Style 4: Ultra Minimal
```lua
-- Separators: · (middle dot)
-- Error: × (multiplication)
-- Warning: ~ (tilde)
-- Added: + (plus)
-- Removed: - (minus)

-- Looks: · NORMAL · main · ×2 ~5 · +3 -1 ·
```

### Style 5: Technical Brackets
```lua
-- Separators: ⟨ ⟩ (angle brackets)
-- Error: ✗ (ballot X)
-- Warning: ⚠ (warning)
-- Added: ⊞ (squared plus)
-- Removed: ⊟ (squared minus)

-- Looks: ⟨ NORMAL ⟩⟨ main ⟩⟨ ✗2 ⚠5 ⟩⟨ ⊞3 ⊟1 ⟩
```

---

## How to Change Icon Style

### Option 1: Use Pre-made Config
```bash
# Copy the custom minimal version
cp ~/.config/nvim/lua/plugins/lualine-minimal-custom.lua ~/.config/nvim/lua/plugins/lualine.lua

# Restart Neovim
nvim
```

### Option 2: Manually Edit
Edit `~/.config/nvim/lua/plugins/lualine.lua`:

**Change diagnostic symbols (around line 31):**
```lua
symbols = {
  error = '■ ',   -- Change this to your preferred symbol
  warn = '△ ',    -- Change this to your preferred symbol
  info = '○ ',    -- Change this to your preferred symbol
  hint = '◇ ',    -- Change this to your preferred symbol
},
```

**Change git diff symbols (around line 47):**
```lua
symbols = {
  added = '⊕ ',      -- Change this
  modified = '⊙ ',   -- Change this
  removed = '⊖ ',    -- Change this
},
```

**Change separators (around line 60):**
```lua
section_separators = { left = '┃', right = '┃' },      -- Change these
component_separators = { left = '┃', right = '┃' },    -- Change these
```

---

## Unicode Character Reference

### Box Drawing
```
─ ━ │ ┃ ┄ ┅ ┆ ┇ ┈ ┉ ┊ ┋
├ ┤ ┬ ┴ ┼ ╋ ╭ ╮ ╯ ╰
║ ═ ╒ ╓ ╔ ╕ ╖ ╗ ╘ ╙ ╚ ╛ ╜ ╝ ╞ ╟ ╠ ╡ ╢ ╣
```

### Block Elements
```
▀ ▁ ▂ ▃ ▄ ▅ ▆ ▇ █ ▉ ▊ ▋ ▌ ▍ ▎ ▏
▐ ░ ▒ ▓ ▔ ▕ ▖ ▗ ▘ ▙ ▚ ▛ ▜ ▝ ▞ ▟
```

### Geometric Shapes
```
■ □ ▢ ▣ ▤ ▥ ▦ ▧ ▨ ▩
● ○ ◉ ◌ ◍ ◎ ◐ ◑ ◒ ◓ ◔ ◕
◆ ◇ ◈ ◊ ◘ ◙
▲ △ ▴ ▵ ▶ ▷ ▸ ▹ ► ▻ ▼ ▽ ▾ ▿ ◀ ◁ ◂ ◃ ◄ ◅
```

### Mathematical Operators
```
⊕ ⊖ ⊗ ⊘ ⊙ ⊚ ⊛ ⊜ ⊝ ⊞ ⊟ ⊠ ⊡
⊢ ⊣ ⊤ ⊥ ⊦ ⊧ ⊨ ⊩ ⊪ ⊫ ⊬ ⊭ ⊮ ⊯
∀ ∁ ∂ ∃ ∄ ∅ ∆ ∇ ∈ ∉ ∊ ∋ ∌ ∍ ∎ ∏
∴ ∵ ∶ ∷ ∸ ∹ ∺ ∻ ∼ ∽ ∾ ∿ ≀ ≁ ≂ ≃
```

### Arrows
```
← ↑ → ↓ ↔ ↕ ↖ ↗ ↘ ↙
⇐ ⇑ ⇒ ⇓ ⇔ ⇕ ⇖ ⇗ ⇘ ⇙
⟵ ⟶ ⟷ ⟸ ⟹ ⟺
```

---

## Testing Icons

To test if icons display correctly in your terminal:

```bash
echo "Separators: ┃ ║ │ ∥"
echo "Errors: ■ ▀ ⊗ ✗ ×"
echo "Warnings: △ ▄ ⊘ ⚠ ~"
echo "Additions: ⊕ ▲ ⊞ ↑ +"
echo "Deletions: ⊖ ▼ ⊟ ↓ -"
```

All symbols should appear as distinct shapes, not boxes or question marks.

---

## Philosophy Behind Each Symbol

**Error (■):** Filled square represents a **blocking issue** - solid, impassable.

**Warning (△):** Triangle represents **caution** - universal warning symbol shape.

**Info (○):** Circle represents **information** - complete, whole information.

**Hint (◇):** Diamond represents **suggestion** - precious tip, optional improvement.

**Added (⊕):** Mathematical circled plus - **positive addition** to codebase.

**Modified (⊙):** Circled dot - **center point changed**, focal point altered.

**Removed (⊖):** Mathematical circled minus - **subtraction** from codebase.

**Separator (┃):** Box vertical - **technical terminal** aesthetic, clean divisions.

---

## Advantages Over Standard Icons

1. **Unique:** Not commonly seen in other configs
2. **Universal:** Works in ANY terminal, ANY font
3. **Meaningful:** Each symbol has logical connection to meaning
4. **Professional:** Clean, technical look
5. **Minimal:** No visual clutter
6. **No Dependencies:** No Nerd Fonts or special setup needed
7. **Not AI-common:** Distinctive from typical AI/LLM suggestions

---

## Making Your Own Icon Set

Want to create your own unique icons? Follow these rules:

1. **Test in your terminal first** - Copy/paste the character and verify it displays
2. **Keep it meaningful** - Symbol should relate to its function
3. **Stay consistent** - Use same style family (all geometric, all math, etc.)
4. **Avoid emoji range** - Unicode 0x1F300-0x1F9FF (needs emoji font support)
5. **Test with multiple fonts** - Try monospace, serif, sans-serif

**Good Unicode ranges for minimal icons:**
- 0x2500-0x257F: Box Drawing
- 0x2580-0x259F: Block Elements
- 0x25A0-0x25FF: Geometric Shapes
- 0x2200-0x22FF: Mathematical Operators
- 0x2190-0x21FF: Arrows

---

**Current Status:** Using Geometric + Mathematical (recommended)  
**Alternative Files:** lualine-minimal-custom.lua (custom icons)  
**Original File:** lualine.lua (simple text fallback)

---

*Last Updated: 2026-02-04*  
*Config: Sphurti Neovim Configuration*
