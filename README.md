# NotchBar

A tiny WoW AddOn for macOS “notched” MacBooks that **aligns UIParent to WorldFrame** to eliminate notch safe-area offsets and prevent UI elements from drifting after reload.

This AddOn **does not** change the 3D render viewport or macOS safe-area handling. It only adjusts the **WoW UI layer** anchoring and positions the top-center widget container.

---

## Features

- ✅ Forces `UIParent` to match `WorldFrame` size to avoid notch safe-area offsets
- ✅ Reapplies alignment automatically if another addon changes it
- ✅ Moves `UIWidgetTopCenterContainerFrame` to `UIParent TOP` with a configurable offset (default `0, -30`)
- ✅ Account-wide SavedVariables

---

## Installation

1. Close World of Warcraft.
2. Download and unpack
3. drag or copy to '/World of Warcraft/_classic_era_/Interface'
   or '/World of Warcraft/_anniversary_/Interface'
4. Start WoW.
5. In the AddOns menu, enable **NotchBar**.

---

## Usage

No slash commands. Install and it applies automatically.

---

## How it works

The AddOn:

- Re-anchors `UIParent` to `WorldFrame` so UI coordinates match full-screen rendering
- Reapplies the anchor periodically and on key events to avoid other addons reverting it
- Repositions `UIWidgetTopCenterContainerFrame` to `UIParent TOP` with `0, -30`

---

## Limitations

- This AddOn cannot:
  - change the game’s **3D render** size or macOS fullscreen safe-area behavior
  - “detect the notch” directly (WoW AddOns don’t have access to macOS safe-area insets)
- Another addon may still fight the anchoring; the periodic reapply should keep it aligned.

---

## Files

### `NotchBar.toc`
Contains metadata and loads `NotchBar.lua`.

### `NotchBar.lua`
Main implementation:
- Aligns `UIParent` to `WorldFrame`
- Repositions `UIWidgetTopCenterContainerFrame`
- Stores settings in `NotchBarDB`
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
