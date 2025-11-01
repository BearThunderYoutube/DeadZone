# How to Import DeadZone into Roblox Studio

## Method 1: Manual Copy-Paste (Easiest)

### Step-by-Step Guide

---

## 1️⃣ Open Roblox Studio

1. Launch **Roblox Studio**
2. Click **New** → Select **Baseplate** template
3. Click **Create**
4. **Save** your place: File → Save to Roblox As → Name it "DeadZone"

---

## 2️⃣ Understanding the Explorer Window

On the right side, you'll see the **Explorer** window showing:
```
- Workspace
- Players
- Lighting
- ReplicatedStorage
- ServerScriptService
- ServerStorage
- StarterGui
- StarterPack
- StarterPlayer
  - StarterCharacterScripts
  - StarterPlayerScripts
```

---

## 3️⃣ Create a Script or LocalScript

### To Create a Script:
1. **Right-click** on the folder (e.g., ServerScriptService)
2. Click **Insert Object** (or press Ctrl+I)
3. Type "Script" and press Enter
4. The script appears - **rename it** by clicking the name

### To Create a LocalScript:
1. Same process, but type "LocalScript" instead

### To Create a ModuleScript:
1. Same process, but type "ModuleScript" instead

---

## 4️⃣ Paste Code into Scripts

### Example: Creating MainServer.lua

1. **Right-click** ServerScriptService
2. Insert Object → **Script**
3. **Rename** it to `MainServer`
4. **Double-click** the script to open it
5. You'll see default code like:
   ```lua
   print("Hello world!")
   ```
6. **Select All** (Ctrl+A) and **Delete**
7. Open `src/ServerScriptService/MainServer.lua` on your computer (in a text editor)
8. **Copy all the code** (Ctrl+A, Ctrl+C)
9. **Paste** into Roblox Studio (Ctrl+V)
10. **Save** (Ctrl+S)

---

## 5️⃣ Complete Import Checklist

### ✅ ServerScriptService (7 Scripts)

For each file below:
- Right-click ServerScriptService → Insert Object → **Script**
- Rename to the name shown
- Open the file from your computer
- Copy all code and paste into Studio

| Script Name | File Location |
|-------------|---------------|
| `MainServer` | `src/ServerScriptService/MainServer.lua` |
| `AISystem` | `src/ServerScriptService/AISystem.lua` |
| `ExtractionSystem` | `src/ServerScriptService/ExtractionSystem.lua` |
| `SessionSystem` | `src/ServerScriptService/SessionSystem.lua` |
| `DataService` | `src/ServerScriptService/DataService.lua` |
| `LootSystem` | `src/ServerScriptService/LootSystem.lua` |
| `TradingSystem` | `src/ServerScriptService/TradingSystem.lua` |

---

### ✅ ReplicatedStorage/Modules (8 ModuleScripts)

**First, create the Modules folder:**
1. Right-click **ReplicatedStorage**
2. Insert Object → **Folder**
3. Rename to `Modules`

**Then add each ModuleScript:**
- Right-click **Modules** folder → Insert Object → **ModuleScript**
- Rename and paste code from files:

| ModuleScript Name | File Location |
|-------------------|---------------|
| `GameSettings` | `src/ReplicatedStorage/Modules/GameSettings.lua` |
| `InventorySystem` | `src/ReplicatedStorage/Modules/InventorySystem.lua` |
| `EquipmentSystem` | `src/ReplicatedStorage/Modules/EquipmentSystem.lua` |
| `WeaponSystem` | `src/ReplicatedStorage/Modules/WeaponSystem.lua` |
| `AttachmentSystem` | `src/ReplicatedStorage/Modules/AttachmentSystem.lua` |
| `SurvivalSystem` | `src/ReplicatedStorage/Modules/SurvivalSystem.lua` |
| `SkillSystem` | `src/ReplicatedStorage/Modules/SkillSystem.lua` |
| `EffectsSystem` | `src/ReplicatedStorage/Modules/EffectsSystem.lua` |

---

### ✅ StarterPlayer/StarterCharacterScripts (1 LocalScript)

1. In Explorer, expand **StarterPlayer**
2. Expand **StarterCharacterScripts**
3. Right-click StarterCharacterScripts → Insert Object → **LocalScript**
4. Rename to `PlayerController`
5. Paste code from `src/StarterPlayer/StarterCharacterScripts/PlayerController.lua`

---

### ✅ StarterPlayer/StarterPlayerScripts (1 LocalScript)

1. Expand **StarterPlayerScripts** (inside StarterPlayer)
2. Right-click → Insert Object → **LocalScript**
3. Rename to `ClientMain`
4. Paste code from `src/StarterPlayer/StarterPlayerScripts/ClientMain.lua`

---

### ✅ StarterGui (5 LocalScripts)

For each UI script:
- Right-click **StarterGui** → Insert Object → **LocalScript**
- Rename and paste code:

| LocalScript Name | File Location |
|------------------|---------------|
| `HUD` | `src/StarterGui/HUD.lua` |
| `InventoryGUI` | `src/StarterGui/InventoryGUI.lua` |
| `MinimapUI` | `src/StarterGui/MinimapUI.lua` |
| `MapUI` | `src/StarterGui/MapUI.lua` |
| `SettingsMenu` | `src/StarterGui/SettingsMenu.lua` |

---

### ✅ Workspace Folders

Create these empty folders in Workspace:
1. Right-click **Workspace**
2. Insert Object → **Folder**
3. Create these folders:
   - `Map`
   - `Zombies`
   - `Loot`
   - `ExtractionPoints`
   - `SafeZone`

---

### ✅ Generate the Map

1. Right-click **Workspace** → Insert Object → **Script**
2. Rename to `MapGenerator`
3. Paste code from `src/Workspace/SimpleMapGenerator.lua`
4. **IMPORTANT**: Scroll to the bottom of the code
5. Find this line (last line):
   ```lua
   -- Uncomment to generate map:
   -- MapGenerator:GenerateSimpleMap()
   ```
6. **Remove the `--`** so it looks like:
   ```lua
   MapGenerator:GenerateSimpleMap()
   ```
7. Click **Play** (F5) - wait a few seconds
8. You should see terrain, buildings, and trees appear
9. Click **Stop**
10. **Delete** the MapGenerator script (you only need to run it once)

---

### ✅ Enable DataStore

1. Click the **Game Settings** icon (gear) at the top
2. Go to **Security** tab
3. Check ✅ **Enable Studio Access to API Services**
4. Click **Save**

---

### ✅ Create Zombie Model (Quick Test Version)

For testing, create a simple zombie:

1. In **ServerStorage**, Insert Object → **Folder**
2. Rename to `ZombieModel`
3. Inside ZombieModel folder:
   - Insert Object → **Part**, rename to `HumanoidRootPart`
   - Insert Object → **Humanoid**
4. That's enough for testing!

(Later you can replace this with a proper zombie character model)

---

## 6️⃣ Final Check

Your Explorer should look like this:

```
📁 Workspace
  📁 Map (empty for now)
  📁 Zombies
  📁 Loot
  📁 ExtractionPoints
  📁 SafeZone
  🌍 Terrain (with grass/buildings after running MapGenerator)

📦 ServerScriptService
  📜 MainServer
  📜 AISystem
  📜 ExtractionSystem
  📜 SessionSystem
  📜 DataService
  📜 LootSystem
  📜 TradingSystem

📦 ReplicatedStorage
  📁 Modules
    📘 GameSettings
    📘 InventorySystem
    📘 EquipmentSystem
    📘 WeaponSystem
    📘 AttachmentSystem
    📘 SurvivalSystem
    📘 SkillSystem
    📘 EffectsSystem

📦 StarterPlayer
  📁 StarterCharacterScripts
    📜 PlayerController (LocalScript)
  📁 StarterPlayerScripts
    📜 ClientMain (LocalScript)

📦 StarterGui
  📜 HUD (LocalScript)
  📜 InventoryGUI (LocalScript)
  📜 MinimapUI (LocalScript)
  📜 MapUI (LocalScript)
  📜 SettingsMenu (LocalScript)

📦 ServerStorage
  📁 ZombieModel
    📦 HumanoidRootPart
    👤 Humanoid
```

---

## 7️⃣ Test the Game!

1. Click **Play** (F5)
2. Check the **Output** window (View → Output)
3. You should see:
   ```
   === DeadZone Server Starting ===
   All systems initialized - Open World Mode
   === DeadZone Server Ready ===
   ```

4. Try the controls:
   - **WASD** - Move
   - **Shift** - Sprint
   - **M** - Open Map
   - **Tab** - Inventory

---

## 📝 Tips

### Opening Files on Your Computer
- **Windows**: Right-click file → Open With → Notepad
- **Mac**: Right-click file → Open With → TextEdit
- Or use VS Code, Sublime Text, etc.

### Copying Code Quickly
1. Open the .lua file
2. Press **Ctrl+A** (Select All)
3. Press **Ctrl+C** (Copy)
4. Go to Roblox Studio
5. Click in the script window
6. Press **Ctrl+A** (Select All in Studio)
7. Press **Ctrl+V** (Paste)
8. Press **Ctrl+S** (Save)

### Common Mistakes
❌ Creating a Script instead of a LocalScript for UI
❌ Creating a LocalScript instead of a Script for server
❌ Putting scripts in the wrong folder
❌ Forgetting to uncomment the MapGenerator line
❌ Not enabling API Services

---

## 🆘 Still Having Trouble?

If you see errors:
1. Check the **Output** window - it tells you what's wrong
2. Make sure script names match exactly (case-sensitive)
3. Make sure you created Scripts vs LocalScripts correctly
4. Make sure all modules are in the Modules folder
5. Re-read TESTING_GUIDE.md for troubleshooting

---

Good luck! Once everything is imported, press F5 and your game should run! 🎮
