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
- Floating keyboard
  + Only works inside SpringBoard

### Enabling Stage Manager
> [!WARNING]
> It is recommended to enable Stage Manager using Control Center module only, so that there will be no risk of bootloop.

#### Modifying MobileGestalt cache
- Open `/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist` in plist editor
- Open `CacheExtra`
- Add a key named `qeaj75wk3HF4DwQ8qbIi7g`, type `Number` and set value to `1`.

#### Creating toggle shortcut
Deprecated. Please use Control Center instead.

## Side effects
- Status bar has the style of iPadOS.
- Control Center layout becomes smaller
- In multitasking modes in landscape, left and right are affected by layout margins.
- App Library grid group going out of bounds
