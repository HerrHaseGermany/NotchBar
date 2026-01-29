# NotchBar

A tiny WoW AddOn for macOS “notched” MacBooks that draws a **black bar at the very top of the screen** to hide UI elements (including other addons’ fullscreen overlays) that appear behind/under the notch area.

This AddOn **does not** change the 3D render viewport or macOS safe-area handling. It only masks the **WoW UI layer**.

---

## Features

- ✅ Black bar anchored to the top of `UIParent` (works in **Fullscreen** and **Fullscreen (Windowed)**)
- ✅ Auto height mode (scales with resolution + UI scale via a ratio)
- ✅ Manual height mode (set it once if you want pixel-perfect)
- ✅ Account-wide SavedVariables
- ✅ Simple slash commands

---

## Installation

1. Close World of Warcraft.
2. Create this folder:

   - Retail: `World of Warcraft/_retail_/Interface/AddOns/NotchBar/`
   - Classic (if needed): `World of Warcraft/_classic_/Interface/AddOns/NotchBar/`

3. Put these files inside:

   - `NotchBar.toc`
   - `NotchBar.lua`

4. Start WoW.
5. In the AddOns menu, enable **NotchBar**.
6. (Optional) Check **Load out of date AddOns** if WoW complains after a patch.

---

## Usage

### Slash commands

- `/notchbar help`  
  Show all commands.

- `/notchbar auto`  
  Enable **auto** mode (recommended). Height is computed as a ratio of screen/UI height and clamped to safe bounds.

- `/notchbar <number>`  
  Enable **manual** mode with a fixed height (example: `/notchbar 74`).

- `/notchbar on`  
  Enable the bar.

- `/notchbar off`  
  Disable the bar.

- `/notchbar status`  
  Show current settings.

### Advanced tuning (optional)

- `/notchbar ratio <number>`  
  Sets the auto-mode ratio (default `0.038`).  
  Example: `/notchbar ratio 0.040`

- `/notchbar clamp <min> <max>`  
  Sets the min/max height used in auto mode (default `50 110`).  
  Example: `/notchbar clamp 60 100`

---

## Recommended settings

- Start with: `/notchbar auto`
- If you want “set and forget” perfect coverage:
  1. Adjust once using `/notchbar 70`, `/notchbar 74`, `/notchbar 80`, etc.
  2. Keep the one that fully masks the notch strip without covering too much UI.

---

## How it works

The AddOn creates a frame anchored to the top edge of `UIParent`:

- The frame is given a very high `FrameStrata` / `FrameLevel`
- A solid black texture fills the frame
- Auto mode computes height as a ratio of `UIParent:GetHeight()`

This means:

- The bar always stays at the top in any WoW display mode
- The bar scales sensibly across UI scale and resolution changes
- The bar hides UI textures drawn underneath it (including many addon overlays)

---

## Limitations

- This AddOn cannot:
  - change the game’s **3D render** size or macOS fullscreen safe-area behavior
  - “detect the notch” directly (WoW AddOns don’t have access to macOS safe-area insets)
- Some UI elements could still appear above the bar if another addon draws at an even higher strata/level (rare). If that happens, increase `FrameStrata` / `FrameLevel` in `NotchBar.lua`.

---

## Files

### `NotchBar.toc`
Contains metadata and loads `NotchBar.lua`.

### `NotchBar.lua`
Main implementation:
- Creates the black top bar
- Stores settings in `NotchBarDB`
- Provides `/notchbar` commands
- Updates on:
  - `PLAYER_LOGIN`
  - `UI_SCALE_CHANGED`
  - `DISPLAY_SIZE_CHANGED`

---

## Troubleshooting

**The bar doesn’t show up**
- Make sure the folder is exactly: `Interface/AddOns/NotchBar/`
- Make sure file names are exactly: `NotchBar.toc` and `NotchBar.lua`
- Check the AddOns menu and enable it
- Enable “Load out of date AddOns” if needed

**The bar is too tall or too short**
- Use manual mode: `/notchbar 74` (try values between 60–100)
- Or tweak auto:
  - `/notchbar ratio 0.040`
  - `/notchbar clamp 60 100`

**I only want it on the internal MacBook display**
- Not implemented by default (WoW doesn’t provide a reliable way to identify which display you’re on from the AddOn API). You can toggle manually with `/notchbar off`.

---

## License

Do whatever you want with it (MIT-style spirit). If you share it, please keep attribution.