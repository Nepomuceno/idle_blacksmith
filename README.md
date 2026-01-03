# Idle Blacksmith

<div align="center">

![Godot Engine](https://img.shields.io/badge/Godot-4.5-blue?logo=godot-engine&logoColor=white)
![License](https://img.shields.io/badge/License-PolyForm%20Strict-red)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux%20%7C%20iOS%20%7C%20Android-lightgrey)

**A fantasy idle game where you forge legendary weapons, collect gold, and ascend to gain permanent bonuses.**

*Forge Your Legend in the Realm of Aethermoor*

</div>

---

## About

In the mystical realm of **Aethermoor**, an ancient forge awaits a master worthy of its flames. As the last apprentice of the legendary Master Thornwick, you must prove yourself at the Eternal Anvil—a sacred site where the boundary between the mortal world and the spirit realm grows thin.

Forge weapons from simple iron daggers to divine artifacts of unimaginable power. Each creation carries the essence of ancient souls, and every strike of your hammer brings you closer to becoming a legendary master smith.

## Features

- **Tap to Forge** - Create weapons with satisfying click mechanics or let auto-forge do the work
- **8 Weapon Tiers** - Progress from Common to Eternal tier weapons
- **Upgrade System** - Boost your click power, passive income, and auto-forge speed
- **Achievements** - Unlock rewards for reaching milestones
- **Ascension System** - Sacrifice progress to gain permanent Ancient Soul bonuses
- **Soul Shop** - Spend Ancient Souls on powerful permanent upgrades
- **Rich Lore** - Immerse yourself in the world of Aethermoor
- **Responsive Design** - Optimized for both mobile and desktop play
- **Offline Progress** - Earn gold even when you're away

## Weapon Tiers

| Tier | Rarity | Description |
|------|--------|-------------|
| Common | Basic | Simple weapons forged from basic iron |
| Uncommon | 1 in 5 | Refined weapons showing sparks of true skill |
| Rare | 1 in 20 | Quality weapons that catch the eye of warriors |
| Epic | 1 in 100 | Exceptional arms with whispers of ancient power |
| Legendary | 1 in 500 | Weapons of myth carrying the soul of fallen heroes |
| Mythic | 1 in 2,500 | Arms that transcend mortal craft |
| Divine | 1 in 10,000 | Forged at the boundary of worlds |
| Eternal | 1 in 50,000 | The pinnacle of smithing, outlasting the stars |

## Getting Started

### Prerequisites

- [Godot Engine 4.5+](https://godotengine.org/download/)
- Export templates (for building releases)

### Running the Game

1. Clone the repository:
   ```bash
   git clone git@github.com:Nepomuceno/idle_blacksmith.git
   cd idle_blacksmith
   ```

2. Open the project in Godot:
   ```bash
   godot project.godot
   ```

3. Press F5 or click the Play button to run the game.

### Building for Release

Export templates must be installed first (Editor > Manage Export Templates).

```bash
# macOS
godot --headless --export-release "macOS" builds/macos/IdleBlacksmith.app

# Windows
godot --headless --export-release "Windows Desktop" builds/windows/IdleBlacksmith.exe

# Linux
godot --headless --export-release "Linux" builds/linux/IdleBlacksmith.x86_64

# Android
godot --headless --export-release "Android" builds/android/IdleBlacksmith.apk

# iOS (macOS only)
godot --headless --export-release "iOS" builds/ios/IdleBlacksmith.ipa
```

See [docs/BUILD_RELEASE.md](docs/BUILD_RELEASE.md) for detailed build instructions.

## Project Structure

```
idle_blacksmith/
├── assets/
│   ├── icons/          # Game item icons & app icons
│   ├── audio/          # Sound effects
│   └── ui/             # UI assets and fonts
├── docs/
│   ├── BUILD_RELEASE.md
│   ├── APP_STORE_GUIDE_PT.md
│   └── privacy_policy.html
├── scenes/
│   ├── main.tscn       # Main game scene
│   └── splash.tscn     # Splash screen
├── scripts/
│   ├── autoload/       # Global singletons
│   ├── data/           # Game data definitions
│   ├── managers/       # System managers
│   └── ui/             # UI controllers
├── tests/              # GUT unit tests
├── project.godot       # Godot project file
└── export_presets.cfg  # Export configurations
```

## Technology

- **Engine**: [Godot 4.5](https://godotengine.org/)
- **Language**: GDScript
- **Renderer**: OpenGL ES 3.0 / Compatibility
- **Testing**: [GUT (Godot Unit Test)](https://github.com/bitwes/Gut)

## Documentation

- [Build & Release Guide](docs/BUILD_RELEASE.md) - How to build for all platforms
- [App Store Guide (PT)](docs/APP_STORE_GUIDE_PT.md) - Complete iOS App Store submission guide
- [Privacy Policy](docs/privacy_policy.html) - Privacy policy for app stores

## Running Tests

```bash
# Run all tests
godot --headless -s addons/gut/gut_cmdln.gd

# Run specific test file
godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_game_data.gd
```

## Contributing

This project uses the PolyForm Strict License which restricts commercial use. 

If you'd like to contribute:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

Copyright (c) 2026 Gabriel Nepomuceno

This software is licensed under the [PolyForm Strict License 1.0.0](LICENSE).

**You may NOT use this software for commercial purposes.**

See the [LICENSE](LICENSE) file for full terms.

## Acknowledgments

- **Godot Engine** - Open source game engine
- **GUT** - Godot Unit Testing framework
- **Kenney** - UI assets and fonts
- Icon assets from various open source collections

## Contact

Gabriel Nepomuceno - [@Nepomuceno](https://github.com/Nepomuceno)

Project Link: [https://github.com/Nepomuceno/idle_blacksmith](https://github.com/Nepomuceno/idle_blacksmith)

---

<div align="center">

**The forge awaits. Begin your legend.**

</div>
