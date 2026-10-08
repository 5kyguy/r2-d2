# Keybindings

Default Hyprland chords. They live under `config/hypr/bindings/` and are copied to `~/.config/hypr/bindings/` on install and update. `bindings.lua` is sourced last, so a personal override goes there.

**Super** is Caps Lock and Left Win. keyd maps Caps Lock to Super system-wide (`default/keyd/default.conf`) and disables Caps Lock state. Use Shift for capitals.

**Super + K** opens a searchable list of the live bindings.

---

## Menus and launchers

| Keybinding | Action |
| ---------- | ------ |
| **Super + Space** | Command bar |
| **Super + Alt + Space** | R2-D2 menu |
| **Super + Escape** | System menu (lock, suspend, reboot, and the rest) |
| **XF86PowerOff** | System menu |
| **Super + Ctrl + Space** | Background selector (wallpaper and accent) |
| **Super + K** | Keybindings browser |
| **Super + Ctrl + E** | Emoji picker |
| **Super + Backslash** | Clipboard history |
| **Super + A** | Ask K-2SO |
| **Super + Alt + A** | K-2SO voice |

---

## Apps

| Keybinding | Action |
| ---------- | ------ |
| **Super + Enter** | Terminal |
| **Super + B** | Browser |
| **Super + Alt + B** | Browser (private) |
| **Super + I** | IDE (Cursor) |
| **Super + M** | Brook with no window, or quit it when it is running |
| **Super + N** | Thunar |
| **Super + C** | Copy |
| **Super + V** | Paste |
| **Super + X** | Cut |
| **Super + Ctrl + Y** | YouTube |
| **Super + Ctrl + W** | WhatsApp |
| **Super + Ctrl + X** | X |
| **Super + Ctrl + T** | Telegram |
| **Super + Ctrl + G** | Steam |

---

## Panels and system

| Keybinding | Action |
| ---------- | ------ |
| **Super + Shift + B** | Bluetooth panel |
| **Super + Shift + W** | Wifi panel |
| **Super + Shift + A** | Audio panel |
| **Super + Shift + I** | Activity (btop) |
| **Super + Shift + S** | Screenshot |
| **Super + Shift + T** | Toggle top bar |
| **Super + Shift + D** | Toggle device display |
| **Super + Shift + M** | Toggle display mirror |
| **Super + Shift + N** | Toggle notification silencing |
| **Super + Shift + P** | Power panel |
| **Super + Shift + L** | Monitor layout (external left) |
| **Super + Alt + T** | Screen time panel |
| **Super + Alt + C** | Pomodoro timer |
| **Super + Alt + G** | Grep search (Grap) |
| **Super + Alt + D** | Drive health panel |
| **Super + Alt + W** | WatchCat dashboard |

WatchCat is a background daemon. **Super + Alt + W** regenerates its HTML dashboard and opens it in the browser. `r2-d2-watchcat-dash <path>` writes the page without opening it.

---

## Windows and workspaces

| Keybinding | Action |
| ---------- | ------ |
| **Super + W** | Close window |
| **Ctrl + Alt + Delete** | Close all windows |
| **Super + T** | Toggle floating and tiling |
| **Super + F** | Fullscreen |
| **Super + Ctrl + F** | Tiled fullscreen |
| **Super + Alt + F** | Full width |
| **Super + O** | Pop window (float and pin) |
| **Super + J** | Toggle split orientation |
| **Super + S** | Toggle scratchpad |
| **Super + Alt + S** | Move window to scratchpad |
| **Super + Arrow** | Move focus |
| **Super + Minus** | Decrease window width |
| **Super + Equal** | Increase window width |
| **Super + Shift + Minus** | Decrease window height |
| **Super + Shift + Equal** | Increase window height |
| **Super + 1** through **Super + 0** | Switch to workspace 1–10 |
| **Super + Shift + 1** through **Super + Shift + 0** | Move the window to that workspace |
| **Super + Shift + comma** | Move window to the previous monitor |
| **Super + Shift + period** | Move window to the next monitor |
| **Super + Page Down** | Next workspace |
| **Super + Page Up** | Previous workspace |
| **Super + scroll** | Change workspace |
| **Super + left drag** | Move window |
| **Super + right drag** | Resize window |

---

## Capture and dictation

| Keybinding | Action |
| ---------- | ------ |
| **Print** | Screenshot |
| **Alt + Print** | Screenrecord menu |
| **Super + Print** | Extract text (OCR) from the screen |
| **Super + D** | Dictate into the focused field (hold, then release) |

While a region picker is on screen:

| Keybinding | Action |
| ---------- | ------ |
| **Enter** | Capture the highlighted window |
| **Ctrl + Enter** | Capture the whole screen |
| **Tab** | Next window |
| **Ctrl + Tab** | Previous window |
| **Arrow** | Select a window in that direction |

---

## Media and brightness

| Keybinding | Action |
| ---------- | ------ |
| **XF86AudioRaiseVolume** / **XF86AudioLowerVolume** | Volume up / down |
| **Alt + XF86AudioRaiseVolume** / **Alt + XF86AudioLowerVolume** | Volume up / down by 1% |
| **XF86AudioMute** | Mute |
| **Super + XF86AudioMute** | Switch audio output |
| **XF86AudioMicMute** | Mute microphone |
| **XF86AudioNext** / **XF86AudioPrev** | Next / previous track |
| **XF86AudioPlay** / **XF86AudioPause** | Play or pause |
| **XF86MonBrightnessUp** / **XF86MonBrightnessDown** | Brightness up / down by 5% |
| **Alt + XF86MonBrightnessUp** / **Alt + XF86MonBrightnessDown** | Brightness up / down by 1% |
| **Shift + XF86MonBrightnessUp** | Brightness to 100% |
| **Shift + XF86MonBrightnessDown** | Brightness to 1% |

---

## Lid

| Keybinding | Action |
| ---------- | ------ |
| **Lid close** | Lock, or follow the lid-close policy |
| **Lid open** | Reconcile the clamshell display |

Layout, scaling, idle, and screensaver toggles are in the menu under **Trigger → Toggle**. They have no dedicated chord.
