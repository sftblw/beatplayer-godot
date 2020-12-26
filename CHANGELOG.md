# Changelog

## Unreleased

### breaking

- methods are renamed
  - `play` -> `play_from_music_offset`
  - `play_absolute` -> `play`
- minimal godot version bumped: 3.1 -> 3.2

### fixed

- utilizes [AudioServer delay](https://docs.godotengine.org/en/3.2/tutorials/audio/sync_with_audio.html) info introduced on Godot 3.2

## [0.1.0] - 2019-06-01
### Added
- static type declaration

### Changed
- migrated to Godot 3.1
- playback is now after-offset value (zero based when even offset exists)

### Fixed
- Prevents audio looping when playing