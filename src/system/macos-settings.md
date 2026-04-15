# macOS Settings

System preferences to configure right after a fresh install.

## Display

- Set scaling to **More Space** for maximum screen real estate
- `System Settings > Displays` → select "More Space"

## Dock

- Remove all default apps from the dock — keep it empty
- Set dock size to **smallest**
- Enable **magnification** for a clean hover effect
- Enable **auto-hide**: toggle "Automatically hide and show the Dock"
- **Position on screen**: Left or Right (preference)
- Disable **"Animate opening applications"**
- Uncheck **"Show suggested and recent apps in Dock"**
- `System Settings > Desktop & Dock` → adjust all settings above

### Remove auto-hide delay

By default the dock has a slight delay before showing. Remove it:

```bash
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.4
killall Dock
```

To reset to default:

```bash
defaults delete com.apple.dock autohide-delay
defaults delete com.apple.dock autohide-time-modifier
killall Dock
```

## Desktop

- **Desktop icons**: hide all — `System Settings > Desktop & Dock > Desktop & Stage Manager` → disable "Show Items On Desktop"
- **Click wallpaper to reveal desktop**: set to **"Only in Stage Manager"** (prevents windows flying away on desktop click)
- **Widgets**: disable if not used — `System Settings > Desktop & Dock` → toggle off widgets

## Hot Corners

- **Bottom-left** → Lock Screen
- `System Settings > Desktop & Dock > Hot Corners...` → set bottom-left to "Lock Screen"
- Useful for quickly locking when in public

## Login Items

- Clean up startup apps — remove anything you don't need on boot
- `System Settings > General > Login Items & Extensions`
- Remove unnecessary apps from the "Open at Login" list
- Review "Allow in the Background" and disable what you don't need

## Finder

- **New Finder windows open**: Home folder — `Finder > Settings > General`
- **Default view**: List view
- **Tabbed browsing**: enable in `Finder > Settings > General`
- **Sidebar**: remove unused folders, disable all tags, reorder by frequency of use
  - `Finder > Settings > Sidebar` → uncheck unwanted items
  - `Finder > Settings > Tags` → uncheck all
- **Keep folders on top**: when sorting by name
  - `Finder > Settings > Advanced` → check "Keep folders on top in windows when sorting by name"
- **Disable extension change warning**:
  - `Finder > Settings > Advanced` → uncheck "Show warning before changing an extension"
- **Default search scope**: Current folder
  - `Finder > Settings > Advanced` → change "When performing a search" to "Search the Current Folder"
- **Show Path Bar**: displays breadcrumb path at bottom
  - `Finder > View > Show Path Bar`
- **Show Status Bar**: displays storage info at bottom
  - `Finder > View > Show Status Bar`
