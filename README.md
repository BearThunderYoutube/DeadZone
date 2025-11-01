# DeadZone

A hardcore open-world survival extraction shooter for Roblox, combining elements from Apocalypse Rising 2 and Escape from Tarkov.

## Features

### Core Gameplay
- **Open World Survival**: Spawn into a persistent open world, gather loot, and extract to save your items
- **Extraction-based gameplay**: Find extraction points scattered across the map, extract to move items to your stash
- **Death = Loss**: Die and you lose everything you're carrying - high risk, high reward
- **Realistic weapon mechanics**: Recoil patterns, ballistics, and weapon handling
- **Advanced survival system**: Manage hunger, thirst, health, bleeding, infections, and fractures
- **AI enemies**: Zombies with pathfinding and dynamic behavior
- **Inventory management**: Weight-based system with rarity tiers
- **Persistent progression**: Level up, gain skills, and build your stash in the safe zone

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
- **Multiple extraction points**: 5 extraction points scattered across the open world map
- **Timed extractions**: 30-second countdown to extract
- **Safe zone**: Teleports you to safe zone where you can access vendors and your stash
- **Stash system**: Extracted items are saved to your permanent stash
- **Fresh start**: After extracting or dying, you start fresh in the open world

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

## How It Works

### Open World Loop
1. **Spawn**: Enter the open world at a random spawn point with basic gear (or nothing if you died)
2. **Loot**: Search containers scattered across the map for weapons, gear, and supplies
3. **Survive**: Fight zombies, manage hunger/thirst, avoid death
4. **Extract**: Reach an extraction point and wait 30 seconds to save your loot to your stash
5. **Safe Zone**: Access vendors to buy/sell items, manage your stash, upgrade gear
6. **Repeat**: Deploy back into the open world to collect more loot

### Death Penalty
- **Lose everything**: All items in your inventory are dropped at your death location
- **Money penalty**: Lose 10% of your money
- **Fresh start**: Respawn with nothing and must re-gear

### Extraction Rewards
- **Keep your loot**: All inventory items move to your permanent stash
- **Money bonus**: Earn $100 base + $10 per item extracted
- **XP bonus**: Gain 500 XP for successful extraction

## Roadmap

- [ ] Map expansion with more locations
- [ ] Additional weapons and attachments
- [ ] Base building system
- [ ] Crafting mechanics
- [ ] Dynamic weather and day/night cycle
- [ ] Vehicle system
- [ ] Faction system
- [ ] More AI enemy types (bandits, mutants)
- [ ] Group/squad system

## Credits

Inspired by:
- Apocalypse Rising 2 (Roblox)
- Escape from Tarkov (Battlestate Games)

## License

This project is for educational purposes.
