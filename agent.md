# Idle Blacksmith - Agent Instructions

## CRITICAL: First Steps for EVERY Session

Before doing ANY work, you MUST:

1. **Read all documentation files:**
   ```
   agent.md      # This file - instructions and workflow
   context.md    # Technical systems and architecture  
   memory.md     # Session history and decisions
   CONTEXT.md    # Detailed game design (auto-loaded)
   ```

2. **After completing work, UPDATE the documentation:**
   - Add session summary to `memory.md`
   - Update `context.md` if systems/architecture changed
   - Keep files concise - prune outdated info
   - **Total lines across all docs should stay under 500**

---

## Project Overview

**Idle Blacksmith** - Fantasy idle/clicker game built with **Godot 4.5**

- **Developer**: Gabriel Nepomuceno
- **Platforms**: Mobile (primary), Desktop/Steam (secondary)
- **Assets**: CC0 licensed from OpenGameArt, Kenney.nl

### Core Loop
Tap to forge weapons -> Earn gold -> Buy upgrades -> Ascend -> Unlock new weapons -> Spend souls on permanent bonuses

---

## Tech Stack

| Component | Details |
|-----------|---------|
| Engine | Godot 4.5.1 |
| Language | GDScript |
| Renderer | OpenGL Compatibility |
| Font | Kenney Future (CC0) |
| Icons | RPG icons from OpenGameArt |

---

## Project Structure

```
first_game/
├── project.godot           # 480x800 base, adaptive layout
├── CONTEXT.md              # Detailed game design doc
├── agent.md                # This file
├── context.md              # Technical context
├── memory.md               # Session history
├── scenes/
│   └── main.tscn           # Tab-based UI layout
├── scripts/
│   ├── main.gd             # UI controller (~1100 lines)
│   └── game_data.gd        # Game state/mechanics (~750 lines)
└── assets/
    ├── icons/              # Weapon/item icons
    └── ui/
        ├── Font/           # Kenney Future fonts
        └── Sounds/         # UI sound effects
```

---

## Key Systems Reference

| System | File | Key Functions |
|--------|------|---------------|
| Gold Economy | game_data.gd | `add_gold()`, `get_weapon_value()` |
| Upgrades | game_data.gd | `purchase_upgrade()`, `_apply_upgrade()` |
| Auto-Forge | main.gd | `_do_auto_forge()`, `auto_forge_timer` |
| Ascension | game_data.gd | `ascend()`, `can_ascend()` |
| Soul Shop | game_data.gd | `purchase_ascension_upgrade()`, `purchase_weapon_upgrade()` |
| Achievements | game_data.gd | `check_achievements()`, `ACHIEVEMENTS` dict |
| Save/Load | game_data.gd | `save_game()`, `load_game()` |
| UI/Tabs | main.gd | `_show_tab()`, `_refresh_*_list()` |
| Responsive Layout | main.gd | `_check_layout()`, `_setup_wide_layout()` |

---

## Running the Game

```bash
# First time (import assets)
godot --editor

# Run game
godot .

# Or press F5 in editor
```

---

## Git Workflow & Conventional Commits

### Commit Message Format

All commits MUST follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Commit Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Code style (formatting, no logic change) |
| `refactor` | Code refactoring (no feature/fix) |
| `perf` | Performance improvement |
| `test` | Adding/updating tests |
| `build` | Build system or dependencies |
| `ci` | CI/CD configuration |
| `chore` | Maintenance tasks |

### Scopes (optional)

| Scope | Area |
|-------|------|
| `ui` | User interface changes |
| `forge` | Forging system |
| `upgrades` | Upgrade system |
| `ascension` | Ascension/souls system |
| `settings` | Settings/config |
| `save` | Save/load system |
| `audio` | Sound effects |
| `release` | Release/build pipeline |

### Examples

```bash
feat(ui): add settings tab with UI scale slider
fix(save): persist shown milestones across sessions
docs: update agent.md with conventional commits guide
refactor(forge): extract weapon data to separate file
ci(release): add automated changelog generation
```

### Release Process

1. Make changes with conventional commits
2. Create a tag: `git tag v0.1.0-beta`
3. Push tag: `git push origin v0.1.0-beta`
4. GitHub Actions will:
   - Build Windows, macOS, Linux
   - Generate changelog from commits since last tag
   - Create GitHub release with all assets

### Tag Format

- **Releases**: `v1.0.0`, `v1.2.3`
- **Pre-releases**: `v0.1.0-beta`, `v1.0.0-rc.1`, `v2.0.0-alpha`

---

## Documentation Update Rules

### When to Update memory.md
- Design decisions made
- Features added/removed
- Bug fixes (what and why)
- Balance changes
- User preferences noted

### When to Update context.md
- Architecture changes
- New mechanics/systems
- Code patterns established
- File structure changes

### Pruning Guidelines
1. Keep only last 5 sessions in memory.md
2. Move stable decisions into context.md as facts
3. Remove outdated/superseded information
4. Consolidate similar entries

---

## Quick Tasks Reference

### Adding a New Upgrade
1. Add to `UPGRADE_DATA` dict in `game_data.gd`
2. Add effect logic in `_apply_upgrade()` function
3. Set `max_level: 1` for one-time purchases

### Adding a New Achievement  
1. Add to `ACHIEVEMENTS` dict in `game_data.gd`
2. Add check in `check_achievements()` function

### Adding a New Weapon
1. Add to `WEAPONS` dict in `main.gd`
2. Add to `WEAPON_BASE_VALUES` in `game_data.gd`
3. Add to `WEAPON_UNLOCK_ASCENSIONS` in `game_data.gd`
4. Add to state dicts: `weapon_multipliers`, `weapon_upgrade_levels`, `items_forged`

---

## Key Constants

```gdscript
# game_data.gd
UPGRADE_COST_MULTIPLIER = 2.5      # Cost scaling per level
DIMINISHING_RETURN_FACTOR = 0.85   # Effect scaling per level
ASCENSION_THRESHOLD = 100000       # Gold required to ascend
MAX_OFFLINE_HOURS = 8.0            # Offline progress cap
OFFLINE_EFFICIENCY = 0.5           # Offline earning rate
WEAPON_UPGRADE_BASE_COST = 3       # Souls for first weapon upgrade
WEAPON_UPGRADE_COST_MULTIPLIER = 1.5
```

---

## Current State (as of 2026-01-03)

### Implemented Features
- Full forge/gold/upgrade loop
- 7 weapons unlocked via ascension milestones
- Auto-forge system with soul boost
- 21 achievements with rewards
- Offline progress (passive + auto-forge)
- Responsive layout (mobile tabs / desktop side-by-side)
- Developer credit in Shop tab
- Reset progress with confirmation

### Removed Systems (do not re-add)
- Mastery system (decay, streaks, bars)
- Weapon-specific upgrades (sharpening, poison, etc.)
- Mastery/streak achievements

### Pending/Future
- Additional visual polish
- More particle effects
- Sound effect improvements
- Additional weapons/content
