# DeadZone - Deployment Guide

This guide will help you deploy the DeadZone game to Roblox Studio.

## Prerequisites

- Roblox Studio installed
- Roblox account
- Basic understanding of Roblox Studio

## Method 1: Manual Import (Recommended for Development)

### Step 1: Prepare Roblox Studio

1. Open Roblox Studio
2. Create a new place or open an existing one
3. Save the place with a name like "DeadZone"

### Step 2: Create Folder Structure

In Roblox Studio Explorer, ensure you have these services:
- ServerScriptService
- ReplicatedStorage
- StarterPlayer
- StarterGui
- Workspace

### Step 3: Import Server Scripts

1. In **ServerScriptService**:
   - Create a new Script named `MainServer`
   - Copy contents from `src/ServerScriptService/MainServer.lua`
   - Repeat for:
     - `AISystem.lua`
     - `ExtractionSystem.lua`
     - `DataService.lua`

### Step 4: Import Shared Modules

1. In **ReplicatedStorage**, create a Folder named `Modules`
2. Inside the Modules folder, create ModuleScripts:
   - `GameSettings` - Copy from `src/ReplicatedStorage/Modules/GameSettings.lua`
   - `InventorySystem` - Copy from `src/ReplicatedStorage/Modules/InventorySystem.lua`
   - `WeaponSystem` - Copy from `src/ReplicatedStorage/Modules/WeaponSystem.lua`
   - `SurvivalSystem` - Copy from `src/ReplicatedStorage/Modules/SurvivalSystem.lua`

### Step 5: Import Client Scripts

1. In **StarterPlayer** → **StarterCharacterScripts**:
   - Create a LocalScript named `PlayerController`
   - Copy from `src/StarterPlayer/StarterCharacterScripts/PlayerController.lua`

2. In **StarterPlayer** → **StarterPlayerScripts**:
   - Create a LocalScript named `ClientMain`
   - Copy from `src/StarterPlayer/StarterPlayerScripts/ClientMain.lua`

### Step 6: Import UI

1. In **StarterGui**:
   - Create a LocalScript named `HUD`
   - Copy from `src/StarterGui/HUD.lua`
   - Create a LocalScript named `InventoryGUI`
   - Copy from `src/StarterGui/InventoryGUI.lua`

### Step 7: Setup Workspace

1. In **Workspace**, create these folders:
   - `Zombies` (for spawned zombies)
   - `Loot` (for loot drops)
   - `ExtractionPoints` (extraction zones will auto-create here)
   - `Map` (your game map)

2. **Optional**: Create a basic spawn location:
   - Insert a SpawnLocation part
   - Position it at (0, 5, 0)

### Step 8: Create Required Storage

1. In **ServerStorage**, create:
   - A Folder named `ZombieModel` (you'll need to create/import a zombie character model)
   - For now, you can duplicate a MeshPart and name it ZombieModel as a placeholder

### Step 9: Configure DataStore (For Production)

1. Go to Game Settings → Security
2. Enable "Enable Studio Access to API Services"
3. For published games, ensure HTTP requests are enabled

### Step 10: Test the Game

1. Click the "Play" button in Roblox Studio
2. Check the Output window for any errors
3. You should see:
   ```
   === DeadZone Server Starting ===
   Core systems initialized
   === DeadZone Server Ready ===
   === DeadZone Client Starting ===
   UI modules loaded
   === DeadZone Client Ready ===
   ```

## Method 2: Using Rojo (Advanced)

### Prerequisites
- Install [Rojo](https://rojo.space/)
- Install Visual Studio Code (recommended)

### Setup

1. Install Rojo CLI:
   ```bash
   npm install -g rojo
   ```

2. Create a `default.project.json` in the DeadZone directory:
   ```json
   {
     "name": "DeadZone",
     "tree": {
       "$className": "DataModel",
       "ReplicatedStorage": {
         "$className": "ReplicatedStorage",
         "Modules": {
           "$path": "src/ReplicatedStorage/Modules"
         }
       },
       "ServerScriptService": {
         "$className": "ServerScriptService",
         "$path": "src/ServerScriptService"
       },
       "StarterPlayer": {
         "$className": "StarterPlayer",
         "StarterCharacterScripts": {
           "$path": "src/StarterPlayer/StarterCharacterScripts"
         },
         "StarterPlayerScripts": {
           "$path": "src/StarterPlayer/StarterPlayerScripts"
         }
       },
       "StarterGui": {
         "$className": "StarterGui",
         "$path": "src/StarterGui"
       }
     }
   }
   ```

3. Start Rojo server:
   ```bash
   rojo serve
   ```

4. In Roblox Studio:
   - Install the Rojo plugin from the Roblox plugin marketplace
   - Click "Connect" in the Rojo plugin
   - Your code will sync automatically

## Publishing to Roblox

### Step 1: Save and Test

1. Thoroughly test your game in Studio
2. Fix any errors shown in the Output window
3. Save your place: File → Save to Roblox

### Step 2: Publish

1. File → Publish to Roblox
2. Choose "Create new game" or update existing
3. Set game details:
   - Name: DeadZone
   - Description: Add your game description
   - Genre: Shooter / Adventure
4. Configure game settings:
   - Max Players: 10-20 recommended
   - Server Size: Medium
5. Click "Create" or "Save"

### Step 3: Configure Game Settings

1. Go to [Roblox Creator Dashboard](https://create.roblox.com/)
2. Select your game
3. Configure:
   - **Basic Settings**: Name, description, icon
   - **Access**: Public/Private
   - **Monetization**: Game passes, developer products
   - **Security**: Enable API services for DataStore

### Step 4: Enable Required Services

In Game Settings → Security:
- ✅ Enable Studio Access to API Services
- ✅ Allow HTTP Requests (if using external APIs)
- ✅ Enable Third Party Sales (for game passes)

## Troubleshooting

### Common Issues

**Issue**: "Events not found" error
- **Solution**: Make sure MainServer.lua runs first and creates the Events folder in ReplicatedStorage

**Issue**: Zombies not spawning
- **Solution**: Create a ZombieModel in ServerStorage (can be a basic character model for testing)

**Issue**: DataStore errors
- **Solution**: Enable "Studio Access to API Services" in Game Settings

**Issue**: UI not showing
- **Solution**: Check that HUD.lua and InventoryGUI.lua are in StarterGui, not StarterPlayer

**Issue**: Player can't move
- **Solution**: Ensure PlayerController.lua is in StarterCharacterScripts, not StarterPlayerScripts

### Testing Checklist

- [ ] Player spawns correctly
- [ ] HUD displays health, stamina, hunger, thirst
- [ ] Movement works (WASD, Sprint, Crouch)
- [ ] Inventory opens with TAB key
- [ ] Zombies spawn near players
- [ ] Extraction points are visible
- [ ] Items can be used from inventory
- [ ] Data saves on player leave

## Next Steps

1. **Create a proper map**:
   - Build locations for looting
   - Add buildings and structures
   - Place extraction points strategically

2. **Design zombie models**:
   - Create or import zombie character models
   - Add animations
   - Place in ServerStorage

3. **Add weapon models**:
   - Create or import gun models
   - Add to ReplicatedStorage/Assets

4. **Configure loot spawns**:
   - Place loot spawn points on the map
   - Assign loot tables

5. **Balance gameplay**:
   - Adjust values in GameSettings.lua
   - Test with players
   - Iterate on feedback

## Additional Resources

- [Roblox Developer Hub](https://create.roblox.com/docs)
- [Roblox Studio Tutorials](https://create.roblox.com/docs/tutorials)
- [Rojo Documentation](https://rojo.space/docs/)
- [Roblox API Reference](https://create.roblox.com/docs/reference/engine)

## Support

For issues or questions:
1. Check the Roblox Output window for errors
2. Review this deployment guide
3. Check the project README.md
4. Consult Roblox Developer Forums

---

Good luck with your DeadZone game development!
