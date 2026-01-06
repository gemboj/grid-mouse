# GridMouse - grid based mouse movement

This is a simple AutoHotkey script that allows you to move your mouse using only your keyboard.

It is meant to provide a fast access to any part of your screen estate.
This is done through a grid-based movement: instead of simply moving your mouse in the direction of pressed button, you
use a grid to jump around, allowing for fast and precise movement.

This is based on another script, which turns CapsLock into a Super key: https://www.autohotkey.com/
I have builit on top of that, reusing the Super mapping and adding my own grid keybinds.

![Showcase](https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExemRrNGdsbDZkZ2lqb3pxdnVqam5vdnU2N2UwbnQ3bnc5ZWtrZ2o0MSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/1s2Y4EU4TdJ9qjpdTn/giphy.gif)

# Installation

1. Install AutoHotkey v2: https://www.autohotkey.com/
1. Download the gridMouse.ahk script and run it.
    - Optional: Download redpointer.cur file and place it alongside the gridMouse.ahk to change your cursor to a fancy red one when the grid is active.

# Quickstart

1. Press {CapsLock + f} to activate the grid.

2. Use one of the keys to jump your mouse cursor to the next cell:
```
U I O
J K L
M , .
```

Repeat the jump until you reach desired place on the screen.

3. Press {Space} to deactivate the grid and invoke LMB.

4. See [Keybinds](#keybinds) section below for all available functions.

# Main functions

1. Move your mouse using only your keyboard. You can reach any piece of your screen in O(log n) keystrokes!
2. Invoke all common mouse buttons: LMB, RMB, MMB, Click&Drag, Scroll, Mouse 4 & 5 buttons
3. Supports multiple monitors. Use {CapsLock + 1/2/3/4} to select active monitor.

# Keybinds

MouseGrid operates in two main modes:
- inactive grid - keyboard behaves like usual, with the exception of CapsLock
- active grid - the grid is active, you can use your keyboard to move your mouse

## Inactive grid

Do your usual things and when needed, activate the grid using one of the:
- {CapsLock + f} - activate the grid across entire screen
- {CapsLock + d} - activate the grid across current active window
- {CapsLock + z} - activate the grid at its last position
- {CapsLock + 1/2/3/4} - activate the grid across entire choosen monitor screen 

## Active grid

With the grid active, you can deactivate it using:
- {Space} - invoke LMB and deactivate the grid
- {Ctrl + Space} - invoke RMB and deactivate the grid
- {CapsLock} - deactivate the grid

With the grid active, you can move your mouse:
- {u/i/o/j/k/l/m/,/.} - move your mouse to one of the grids subcells and scale the grid to fit within that cell
- {CapsLock + u/i/o/j/l/m/,/.} - move your entire grid without scaling it
- {CapsLock + k} - scale the grid up, without changing cursor position.
- {z} - undo last grid move
- {CapsLock + z} - redo last grid move undo

With the grid active, you can invoke your mouse buttons:
- {f/s/e} - LMB/RMB/MMB
- {d/c/x/v} - Mouse scroll up/down/left/right
- {w/r} - Mouse button 4/5 (back/forward)
- {Tab + f} - Click LMB and hold, press again to release. Can be used for Click&Drag.

All of the shortcuts from the [Inactive grid](#inactive-grid) section still works.
They will redraw the grid at their designated location and keep the grid active.

# Tips

1. When the grid is active, dont use your keyboard for anything else than operating the grid.

MouseGrid has many keyboard shortcuts which will mess up with whathever you try to do.
Instead, close the grid by pressing CapsLock, do your thing, and then reinvoke the grid to its last position using {CapsLock + z}.

