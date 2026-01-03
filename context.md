# Idle Blacksmith - Technical Context

## Architecture Overview

### Two Main Scripts

**game_data.gd** (~750 lines) - GameData class
- All game state variables
- Economy calculations
- Save/load (JSON to user://savegame.save)
- Achievement logic
- Ascension/prestige system

**main.gd** (~1100 lines) - UI Controller
- Tab navigation system
- Weapon grid creation
- Forge button and effects
- Upgrade/achievement/shop UI generation
- Responsive layout handling
- Audio playback

### Scene Structure (main.tscn)

```
Main (Control)
├── Background (ColorRect)
└── MainLayout (VBoxContainer)
    ├── Header (PanelContainer)
    │   └── GoldLabel, PassiveLabel, AscensionLabel
    ├── ContentArea (PanelContainer)
    │   ├── ForgeContent (visible by default)
    │   ├── UpgradesContent
    │   ├── AchieveContent
    │   └── ShopContent
    └── TabBar (PanelContainer) - hidden on wide layout
        └── TabForge, TabUpgrades, TabAchieve, TabShop
```

---

## Responsive Layout System

### Detection (`_check_layout`)
- Wide: viewport width >= 900px AND landscape orientation
- Triggers `_apply_layout()` on change

### Mobile Mode (Portrait)
- Tab bar visible at bottom
- Single content panel visible at a time
- Larger forge button (280x90)

### Desktop Mode (Landscape Wide)
- Tab bar hidden
- ForgeContent + UpgradesContent side by side in HBoxContainer
- Mini nav buttons (ACHIEVEMENTS, SHOP) in header
- Back button added to Achieve/Shop when opened
- Smaller forge button (240x70)

---

## Upgrade System

### Data Structure
```gdscript
const UPGRADE_DATA = {
    "upgrade_key": {
        "name": "Display Name",
        "desc": "Description",
        "base_cost": 100.0,
        "icon": "icon.png",
        "category": "general",
        "visibility": 0.5,      # Show when gold >= cost * visibility
        "base_effect": 2.0,     # Effect amount
        "effect_type": "click_power",  # or passive_income, auto_forge, combo, multiplier
        "max_level": 1          # Optional - omit for unlimited
    }
}
```

### Effect Types
- `click_power`: Adds to click_power (with diminishing returns)
- `passive_income`: Adds to passive_income
- `auto_forge`: Adds forges per second
- `combo`: Adds to both click_power and passive_income
- `multiplier`: One-time multiplier to all income sources

### Diminishing Returns Formula
```gdscript
effect = base_effect * pow(0.85, current_level)
```

---

## Soul Shop

### Soul Upgrades (Permanent)
Stored in `ascension_upgrades` dict. Cost = base_cost * (level + 1)

| Key | Effect |
|-----|--------|
| soul_power | +10% click power per level |
| soul_income | +10% passive income per level |
| soul_luck | +5% better tier chance per level |
| soul_forge | +10% auto-forge speed per level |

### Weapon Upgrades
Stored in `weapon_upgrade_levels` dict. Each level gives +25% to weapon value.
Cost: `3 * pow(1.5, level)` souls

---

## Save System

JSON format saved to `user://savegame.save`

Key fields:
- Currency: gold, total_gold_earned, highest_gold_ever, lifetime_gold
- Progression: ancient_souls, total_ascensions, unlocked_tier
- Stats: click_power, passive_income, auto_forge_rate
- Per-weapon: items_forged, weapon_multipliers, weapon_upgrade_levels
- Upgrades: upgrades dict, discovered_upgrades array
- Meta: last_save_timestamp (for offline progress)

---

## Signals

```gdscript
signal gold_changed(new_amount: float)
signal ascension_available()
signal ascended(new_souls: int)
signal achievement_unlocked(achievement_id: String)
```

---

## Timer Systems

| Timer | Interval | Purpose |
|-------|----------|---------|
| passive_timer | 1.0s | Add passive_income to gold |
| auto_forge_timer | 1/rate | Trigger auto-forge |
| autosave_timer | 30s | Save game state |

---

## Node References (unique names)

UI uses `%NodeName` syntax for unique node references:
- `%GoldLabel`, `%PassiveLabel`, `%AscensionLabel`
- `%ForgeButton`, `%AscendButton`
- `%MainWeaponIcon`, `%MainWeaponLetter`, `%WeaponNameLabel`
- `%ForgeContent`, `%UpgradesContent`, `%AchieveContent`, `%ShopContent`
- `%UpgradesList`, `%AchieveList`, `%ShopList`
- `%WeaponGrid`, `%TabBar`
- `%TabForge`, `%TabUpgrades`, `%TabAchieve`, `%TabShop`
