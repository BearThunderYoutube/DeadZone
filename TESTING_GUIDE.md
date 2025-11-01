# DeadZone - Testing Guide

Quick guide to test your game in Roblox Studio.

## Step 1: Open Roblox Studio

1. Open **Roblox Studio**
2. Click **New** → **Baseplate** (or any blank template)
3. Save the place as "DeadZone"

## Step 2: Import Server Scripts

### ServerScriptService
1. In Explorer, expand **ServerScriptService**
2. Create the following **Scripts** (NOT LocalScripts):
   - Right-click ServerScriptService → Insert Object → Script
   - Name each script and copy the code from these files:

   **MainServer** - Copy from `src/ServerScriptService/MainServer.lua`
   **AISystem** - Copy from `src/ServerScriptService/AISystem.lua`
   **ExtractionSystem** - Copy from `src/ServerScriptService/ExtractionSystem.lua`
   **SessionSystem** - Copy from `src/ServerScriptService/SessionSystem.lua`
   **DataService** - Copy from `src/ServerScriptService/DataService.lua`
   **LootSystem** - Copy from `src/ServerScriptService/LootSystem.lua`
   **TradingSystem** - Copy from `src/ServerScriptService/TradingSystem.lua`

## Step 3: Import Shared Modules

### ReplicatedStorage
1. In **ReplicatedStorage**, create a **Folder** named `Modules`
2. Inside the Modules folder, create **ModuleScripts**:
   - Right-click Modules → Insert Object → ModuleScript
   - Name each and copy code from:

   **GameSettings** - `src/ReplicatedStorage/Modules/GameSettings.lua`
   **InventorySystem** - `src/ReplicatedStorage/Modules/InventorySystem.lua`
   **EquipmentSystem** - `src/ReplicatedStorage/Modules/EquipmentSystem.lua`
   **WeaponSystem** - `src/ReplicatedStorage/Modules/WeaponSystem.lua`
   **AttachmentSystem** - `src/ReplicatedStorage/Modules/AttachmentSystem.lua`
   **SurvivalSystem** - `src/ReplicatedStorage/Modules/SurvivalSystem.lua`
   **SkillSystem** - `src/ReplicatedStorage/Modules/SkillSystem.lua`
   **EffectsSystem** - `src/ReplicatedStorage/Modules/EffectsSystem.lua`

## Step 4: Import Client Scripts

### StarterPlayer → StarterCharacterScripts
1. In **StarterPlayer**, expand **StarterCharacterScripts**
2. Create a **LocalScript** named `PlayerController`
   - Copy from `src/StarterPlayer/StarterCharacterScripts/PlayerController.lua`

### StarterPlayer → StarterPlayerScripts
1. In **StarterPlayer**, expand **StarterPlayerScripts**
2. Create a **LocalScript** named `ClientMain`
   - Copy from `src/StarterPlayer/StarterPlayerScripts/ClientMain.lua`

## Step 5: Import UI Scripts

### StarterGui
1. In **StarterGui**, create **LocalScripts**:

   **HUD** - `src/StarterGui/HUD.lua`
   **InventoryGUI** - `src/StarterGui/InventoryGUI.lua`
   **MinimapUI** - `src/StarterGui/MinimapUI.lua`
   **MapUI** - `src/StarterGui/MapUI.lua`
   **SettingsMenu** - `src/StarterGui/SettingsMenu.lua`

## Step 6: Setup Workspace

### Create Folders
1. In **Workspace**, create these **Folders**:
   - `Map`
   - `Zombies`
   - `Loot`
   - `ExtractionPoints`
   - `SafeZone`

### Generate the Map
1. In **Workspace**, create a **Script** named `MapGenerator`
2. Copy code from `src/Workspace/SimpleMapGenerator.lua`
3. **IMPORTANT**: At the bottom of the script, uncomment the last line:
   ```lua
   MapGenerator:GenerateSimpleMap()
   ```
4. Click the **Play** button briefly (this runs the map generator)
5. Stop the game
6. **Delete or disable** the MapGenerator script (you only need to run it once)
7. You should now see terrain, roads, buildings, and trees in your Workspace

## Step 7: Enable API Services

**IMPORTANT for DataStore to work:**
1. Go to **Home** → **Game Settings** (or click the gear icon)
2. Go to **Security** tab
3. Check ✅ **Enable Studio Access to API Services**
4. Click **Save**

## Step 8: Create Placeholder Zombie Model

The AI system needs a zombie model to spawn. For testing:

1. In **ServerStorage**, create a **Folder** named `ZombieModel`
2. Inside it, create a simple model:
   - Insert a **Part** named "HumanoidRootPart"
   - Add a **Humanoid** object to the folder
   - Add a few more parts for the body (optional)

OR just create a basic R15/R6 character rig and name it `ZombieModel`

## Step 9: Test the Game!

1. Click the **Play** button (F5)
2. Your character should spawn in the world
3. You should see:
   - ✅ HUD showing health, stamina, hunger, thirst
   - ✅ Simple buildings and trees
   - ✅ Roads

### Test Controls:
- **WASD** - Move
- **Left Shift** - Sprint (watch stamina drain)
- **Left Control** - Crouch
- **Tab** - Open Inventory
- **M** - Open Map (should show your location)
- **Esc** - Settings menu

### Test Features:
1. **Map** - Press M and verify you see:
   - Your green marker moving
   - 5 blue extraction points
   - Grid coordinates

2. **Movement** - Sprint and watch stamina decrease

3. **Extraction** - Walk to an extraction point (blue marker on map)
   - Should see "Extracting... 10 seconds" message
   - After 10 seconds, teleport to safe zone

4. **Inventory** - Press Tab
   - You should have starter items (Glock19, Bandages, Water, etc.)

## Common Issues

### "Events not found" error
**Solution**: Make sure MainServer.lua runs first. Check Output window for errors.

### Zombies not spawning
**Solution**: Create the ZombieModel in ServerStorage (see Step 8)

### Map doesn't show anything
**Solution**: Make sure you ran the MapGenerator script and created the terrain

### DataStore errors
**Solution**: Enable "Studio Access to API Services" in Game Settings → Security

### UI not showing
**Solution**:
- HUD.lua, InventoryGUI.lua, MinimapUI.lua, MapUI.lua, SettingsMenu.lua should all be in StarterGui
- They should be LocalScripts, not regular Scripts

### Player can't move
**Solution**: PlayerController.lua must be in StarterPlayer → StarterCharacterScripts as a LocalScript

## Quick Testing Checklist

- [ ] Server scripts in ServerScriptService
- [ ] Modules in ReplicatedStorage → Modules
- [ ] Client scripts in correct StarterPlayer locations
- [ ] UI scripts in StarterGui
- [ ] Workspace folders created
- [ ] Map generated (terrain visible)
- [ ] API Services enabled
- [ ] ZombieModel in ServerStorage
- [ ] Press Play and check Output for errors

## Output Messages You Should See

When you press Play, the Output window should show:
```
=== DeadZone Server Starting ===
All systems initialized - Open World Mode
=== DeadZone Server Ready ===
Game Mode: Open World Survival
Active Systems: AI, Extraction, Loot, Trading, Sessions, Skills, Data
```

And on the client:
```
=== DeadZone Client Starting ===
UI modules loaded
HUD initialized
InventoryGUI initialized
MinimapUI initialized - Open World Mode
MapUI initialized - Press M to open map
SettingsMenu initialized
=== DeadZone Client Ready ===
```

## Need Help?

Check the **Output** window (View → Output) for error messages. Most issues will show red error text telling you what's wrong.

Good luck testing DeadZone! 🎮
