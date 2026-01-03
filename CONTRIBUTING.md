# Contributing to Idle Blacksmith

Thank you for your interest in contributing to Idle Blacksmith! This document provides guidelines and information for contributors.

## License Notice

This project is licensed under the **PolyForm Strict License 1.0.0**, which means:

- You **cannot** use this software for commercial purposes
- You **can** use it for personal, educational, and non-commercial purposes
- You **can** contribute improvements back to the project

By contributing, you agree that your contributions will be licensed under the same terms.

## How to Contribute

### Reporting Bugs

1. Check existing [issues](https://github.com/Nepomuceno/idle_blacksmith/issues) to avoid duplicates
2. Create a new issue with:
   - Clear, descriptive title
   - Steps to reproduce the bug
   - Expected vs actual behavior
   - Godot version and platform
   - Screenshots if applicable

### Suggesting Features

1. Check existing issues for similar suggestions
2. Create a new issue with:
   - Clear description of the feature
   - Why it would benefit the game
   - Any implementation ideas (optional)

### Submitting Changes

1. **Fork** the repository
2. **Create a branch** for your feature/fix:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/bug-description
   ```
3. **Make your changes** following the code style guidelines below
4. **Test your changes** thoroughly
5. **Commit** with clear messages:
   ```bash
   git commit -m "Add: new upgrade type for passive income"
   git commit -m "Fix: weapon tier calculation error"
   ```
6. **Push** to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Create a Pull Request** with:
   - Clear description of changes
   - Reference to related issues (if any)
   - Screenshots for UI changes

## Code Style Guidelines

### GDScript

Follow the [official GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html):

```gdscript
# Use snake_case for variables and functions
var player_health: int = 100
func calculate_damage() -> float:

# Use PascalCase for classes
class_name WeaponData

# Use SCREAMING_SNAKE_CASE for constants
const MAX_WEAPON_TIER: int = 8

# Type hints are encouraged
func add_gold(amount: float) -> void:
    gold += amount

# Document public functions
## Calculates the value of a forged weapon based on tier and upgrades.
## Returns the gold value as a float.
func calculate_weapon_value(tier: int) -> float:
```

### File Organization

- **Scenes** go in `scenes/`
- **Scripts** go in `scripts/` with appropriate subdirectory
- **Assets** go in `assets/` organized by type
- **Tests** go in `tests/unit/` or `tests/integration/`

### Commit Messages

Use prefixes to categorize commits:

| Prefix | Usage |
|--------|-------|
| `Add:` | New features or content |
| `Fix:` | Bug fixes |
| `Update:` | Improvements to existing features |
| `Remove:` | Removing code or features |
| `Refactor:` | Code changes without behavior changes |
| `Docs:` | Documentation only |
| `Test:` | Adding or updating tests |
| `Style:` | Formatting, code style changes |

Examples:
```
Add: mythic tier weapons with special effects
Fix: gold not saving correctly on ascension
Update: improve upgrade button responsiveness
Refactor: extract weapon calculation to separate class
Docs: update README with new features
```

## Running Tests

Before submitting, ensure all tests pass:

```bash
# Run all tests
godot --headless -s addons/gut/gut_cmdln.gd

# Run with verbose output
godot --headless -s addons/gut/gut_cmdln.gd -glog=3
```

### Writing Tests

Add tests for new functionality in `tests/unit/` or `tests/integration/`:

```gdscript
extends GutTest

func test_weapon_value_calculation():
    var game_data = GameData.new()
    var value = game_data.calculate_weapon_value(1)  # Common tier
    assert_gt(value, 0, "Weapon value should be positive")

func test_gold_increases_on_forge():
    var game_data = GameData.new()
    var initial_gold = game_data.gold
    game_data.forge_weapon()
    assert_gt(game_data.gold, initial_gold, "Gold should increase after forging")
```

## Project Architecture

Understanding the codebase:

```
scripts/
├── autoload/
│   └── game_events.gd      # Global event bus (signals)
├── data/
│   ├── game_state.gd       # Core game state
│   ├── upgrade_data.gd     # Upgrade definitions
│   ├── weapon_data.gd      # Weapon definitions
│   ├── tier_data.gd        # Tier definitions
│   ├── achievement_data.gd # Achievement definitions
│   └── lore_data.gd        # Story and flavor text
├── managers/
│   ├── save_manager.gd     # Save/load functionality
│   ├── forge_manager.gd    # Forging logic
│   ├── upgrade_manager.gd  # Upgrade logic
│   ├── achievement_manager.gd
│   ├── ascension_manager.gd
│   ├── audio_manager.gd
│   └── ad_manager.gd       # Ads (disabled by default)
└── ui/
    ├── forge_ui.gd
    ├── upgrades_ui.gd
    ├── achievements_ui.gd
    ├── shop_ui.gd
    └── splash_screen.gd
```

## Development Setup

1. Clone your fork:
   ```bash
   git clone git@github.com:YOUR_USERNAME/idle_blacksmith.git
   ```

2. Add upstream remote:
   ```bash
   git remote add upstream git@github.com:Nepomuceno/idle_blacksmith.git
   ```

3. Keep your fork updated:
   ```bash
   git fetch upstream
   git checkout main
   git merge upstream/main
   ```

## Questions?

- Open a [Discussion](https://github.com/Nepomuceno/idle_blacksmith/discussions) for general questions
- Open an [Issue](https://github.com/Nepomuceno/idle_blacksmith/issues) for bugs or feature requests

Thank you for contributing!
