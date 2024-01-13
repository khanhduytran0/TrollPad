# TrollPad
Troll SpringBoard into thinking it's running on iPadOS

## Features
- Grid app switcher
- Multitasking button
- Floating dock
  + Recent apps
  + App Library
- Split View
- Slide Over
- Stage Manager
  + Requires iOS 16 or later
  + External display support is untested
  + Additional steps required
- Floating keyboard
  + Only works inside SpringBoard

### Enabling Stage Manager
> [!CAUTION]
> - When uninstalling this tweak with Stage Manager still enabled, do not remove MobileGestalt key. Doing so can cause bootloop. It's best to keep MobileGestalt key there.
> - #4: Do not disable `Show Dock`. Doing so may cause respring loop when rotating device to landscape. 

#### Modifying MobileGestalt cache
- Open `/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist` in plist editor
- Open `CacheExtra`
- Add a key named `qeaj75wk3HF4DwQ8qbIi7g`, type `Number` and set value to `1`.

#### Creating toggle shortcut
- Open Shortcuts app
- Create an empty shortcut
- Add `Toggle Stage Manager` action
- Enable both `Show Dock` and `Show Recent Apps`
- Save and run the shortcut

## Side effects
- Status bar has the style of iPadOS.
- Control Center layout becomes smaller
- In multitasking modes in landscape, left and right are affected by layout margins.
- App Library grid group going out of bounds
