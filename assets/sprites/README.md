# Sprite assets

Pixel art at 16 x 16 per frame, transparent background, drawn for nearest-neighbor filtering.

- `player.png`: 48 x 48 sheet, 3 x 3 frames. Rows are facing down, up and side (flip for left). Columns are idle, step A and step B. Used by `player.tscn` with `hframes = 3`, `vframes = 3`.
- `fishing_spot_marker.png`: 96 x 16 strip, 6 frames: `!`, fish 1, fish 2, then 1, 2 and 3 dots. Used by `fishing_spot.tscn` with `hframes = 6`.
