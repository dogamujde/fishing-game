# fishing-game
ECS 179 team project

## Changes in this round

### Game mechanics
- **Fishing spots have states.** Each spot's marker shows what you can do there:
  - Player far away: a floating `!` bubble.
  - Player inside the spot's area (48 px radius): the bubble switches to an animated fish. Only now can you press E to fish.
  - After pressing E: the bubble shows an animated `...` while fishing. Pressing E again does nothing until fishing ends.
  - Fishing ends: the marker disappears and the spot can't be fished.
- **Spots respawn after 5 seconds.** A used spot comes back 5 s after fishing ends, showing the fish if the player is still standing there and the `!` otherwise. The timer pauses while the text box is open. Set it per spot with `respawn_time`.
- **XP is given when fishing ends, not on the E press.** Each catch shows "You caught a fish! +40 XP" in the text box, followed by the level-up message if the catch levels you up. XP per catch is `FISH_XP` in `scripts/main.gd` (currently 40, so the first level-up comes on the 3rd catch).
- **Placeholder fishing length.** Until Joseph's minigame is hooked up, `main.gd` waits 2 s and then calls `spot.finish_fishing()`. When the minigame is ready, call `finish_fishing()` when it ends and remove the wait.

### UI
- **XP bar** (`scripts/xp_bar.gd`, added to `main.tscn`): a 64 x 6 px green bar in the top-left corner with `Lv N  xp/needed` next to it. The bar's maximum is the XP needed for the current level, and it updates on `GameState.xp_changed`.

### Art
- **Player sprite** (`assets/sprites/player.png`): a 16 x 16 fisherman with a walk animation, saved as a 3 x 3 sheet. The rows are facing down, up and side (left uses the side frames flipped), and the columns are idle, step A and step B. `player.gd` picks the facing from the movement direction, plays idle, A, idle, B at `walk_fps` (default 8), bobs the sprite up 1 px on step frames, and returns to the idle frame when stopped or when `can_move` is false.
- **Fishing marker** (`assets/sprites/fishing_spot_marker.png`): a 6-frame strip with `!`, two fish frames and three dot frames. It bobs up and down; `bob_height`, `bob_speed` and `frame_fps` are exported on `FishingSpot`.
