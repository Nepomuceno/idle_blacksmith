# Idle Blacksmith - Session Memory

## Session 5: Documentation & Desktop Layout (2026-01-03)

### Completed
1. **Developer Credit** - Added "Developed by Gabriel Nepomuceno" to Shop tab
2. **Responsive Desktop Layout** - When screen >= 900px wide (landscape):
   - Tab bar hidden
   - Forge + Upgrades shown side-by-side in HBoxContainer
   - Mini nav buttons (ACHIEVEMENTS, SHOP) added to header
   - Back button when viewing Achieve/Shop in wide mode
3. **Documentation Update**:
   - Updated `agent.md` with clear instructions to read/update docs each session
   - Updated `context.md` with current architecture details
   - Consolidated memory.md

### Key Code Changes
- `main.gd`: Added `_setup_wide_layout()`, `_setup_mobile_layout()`, `_on_wide_achieve_pressed()`, `_on_wide_shop_pressed()`, `_add_back_button_to_panel()`
- `main.tscn`: Added `unique_name_in_owner = true` to TabBar node
- Shop tab now includes developer credit at bottom

---

## Session 4: Major Rebalance (2026-01-03)

### Removed Systems
- **Mastery system entirely** (decay, streaks, bars, upgrades)
- **Weapon-specific upgrades** (Sharpening Stone, Poison Tips, etc.)
- **Mastery/streak achievements**

### Added Systems
- **Weapon unlocking via ascension**: Sword(0), Dagger(1), Axe(2), Bow(3), Spear(5), Mace(7), Staff(10)
- **Auto-Forge upgrade**: Repeatable, adds forges/sec with diminishing returns
- **Soul Forge upgrade**: +10% auto-forge speed per level (soul shop)
- **Aggressive cost scaling**: UPGRADE_COST_MULTIPLIER = 2.5
- **Diminishing returns**: DIMINISHING_RETURN_FACTOR = 0.85
- **One-time multipliers**: Enchanted Forge (x1.5), Dragon Bellows (x2), Time Warp (x3)
- **Weapon upgrades in Soul Shop**: +25% value per level, costs souls
- **Reset Progress button**: In Shop tab with confirmation dialog

### Bug Fixes
- Fixed %TabBar reference error
- Fixed achievement display errors for removed achievements in old saves

### Visual Improvements
- Kenney Future font integration
- Larger forge button with glow effect (120x120 weapon icon)
- Better color scheme and shadows

---

## Session 3: Mobile UI (Previous)
- Tab-based navigation
- Adaptive layout for mobile+desktop
- Letter fallbacks for icons
- Scientific notation for large numbers

## Session 2: Upgrades & Ascension (Previous)
- Upgrade system with categories and discovery
- Ascension/prestige with soul shop

## Session 1: Core Setup (Previous)
- Godot 4.5 project with CC0 assets
- 7 weapons, basic forge loop

---

## User Preferences
- Minimal but polished visuals
- Simplicity over complex systems
- Meaningful progression tied to ascension
- CC0/free assets only (OpenGameArt, Kenney.nl)
- Adaptive UI for mobile + desktop
