# DeadZone

A hardcore survival extraction shooter for Roblox, combining elements from Apocalypse Rising 2 and Escape from Tarkov.

## Features

### Core Gameplay
- **Extraction-based gameplay**: Complete raids, gather loot, and extract safely to keep your items
- **Realistic weapon mechanics**: Recoil patterns, ballistics, and weapon handling
- **Advanced survival system**: Manage hunger, thirst, health, bleeding, infections, and fractures
- **AI enemies**: Zombies with pathfinding and dynamic behavior
- **Inventory management**: Weight-based system with rarity tiers
- **Persistent progression**: Level up, gain skills, and build your stash

### Systems

#### Player Systems
- **Stamina-based movement**: Sprint management with dynamic regeneration
- **Multiple stances**: Walk, sprint, and crouch
- **Health and damage**: Localized damage with headshot multipliers
- **Status effects**: Bleeding, infection, pain, hunger, and thirst

#### Weapon System
- **Realistic ballistics**: Bullet drop, velocity, and range
- **Recoil patterns**: Unique patterns for each weapon
- **Multiple fire modes**: Auto, semi-auto, and burst
- **Weapon durability**: Maintain your weapons for optimal performance

#### Survival Mechanics
- **Hunger & Thirst**: Decay over time, affecting performance
- **Medical system**: Bandages, medkits, painkillers, antibiotics
- **Status effects**: Bleeding, infections, fractures
- **Death penalties**: Drop items on death (configurable)

#### AI System
- **Zombie AI**: Dynamic spawning based on player proximity
- **Pathfinding**: NavMesh-based intelligent movement
- **Behavior states**: Idle, wander, chase, and attack
- **Loot drops**: Zombies drop items on death

#### Extraction System
- **Multiple extraction points**: Scattered across the map
- **Timed extractions**: 30-second countdown
- **Safe zones**: Protected areas for stash management
- **Extraction types**: Open, timed, and paid extractions

#### Data Persistence
- **Profile system**: Levels, skills, and statistics
- **Stash storage**: Safe storage for extracted items
- **Auto-save**: Regular data saving
- **Achievements**: Track your progress

## Project Structure

```
DeadZone/
├── src/
│   ├── ServerScriptService/
│   │   ├── MainServer.lua
│   │   ├── AISystem.lua
│   │   ├── ExtractionSystem.lua
│   │   └── DataService.lua
│   ├── ReplicatedStorage/
│   │   ├── Modules/
│   │   │   ├── GameSettings.lua
│   │   │   ├── InventorySystem.lua
│   │   │   ├── WeaponSystem.lua
│   │   │   └── SurvivalSystem.lua
│   │   └── Assets/
│   ├── StarterPlayer/
│   │   ├── StarterCharacterScripts/
│   │   │   └── PlayerController.lua
│   │   └── StarterPlayerScripts/
│   │       └── ClientMain.lua
│   ├── StarterGui/
│   │   ├── HUD.lua
│   │   └── InventoryGUI.lua
│   └── Workspace/
│       ├── Map/
│       └── ExtractionPoints/
├── README.md
├── DEPLOYMENT.md
└── .gitignore
```

## Configuration

Edit `GameSettings.lua` to customize:
- Player stats (health, stamina, hunger, thirst)
- Weapon parameters (damage, recoil, fire rate)
- AI behavior (spawn rates, detection range, damage)
- Extraction settings (time, points, penalties)
- Loot rarity and spawn rates

## Controls

- **WASD**: Move
- **Left Shift**: Sprint
- **Left Control**: Crouch
- **Right Mouse Button**: Aim down sights
- **Tab**: Open inventory
- **E**: Interact/Loot
- **R**: Reload
- **1-5**: Weapon hotkeys

## Item Rarity System

- **Common** (Gray): Basic items
- **Uncommon** (Green): Improved gear
- **Rare** (Blue): Advanced equipment
- **Epic** (Purple): High-tier items
- **Legendary** (Orange): Rare and powerful gear

## Weapons

### Assault Rifles
- **AK-47**: 35 damage, 600 RPM, 7.62x39mm
- **M4A1**: 32 damage, 750 RPM, 5.56x45mm

### Pistols
- **Glock 19**: 22 damage, 400 RPM, 9mm

## Development

### Prerequisites
- Roblox Studio
- Git

### Installation
See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed setup instructions.

## Roadmap

- [ ] Additional weapons and attachments
- [ ] Base building system
- [ ] Crafting mechanics
- [ ] Trading system
- [ ] Raid instances/matchmaking
- [ ] Dynamic weather
- [ ] Vehicle system
- [ ] Faction system
- [ ] More AI enemy types

## Credits

Inspired by:
- Apocalypse Rising 2 (Roblox)
- Escape from Tarkov (Battlestate Games)

## License

This project is for educational purposes.
