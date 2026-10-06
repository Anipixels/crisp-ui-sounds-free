# Asset Library submission - Crisp UI Sounds Free

Paste these into https://godotengine.org/asset-library/asset/submit (log in first). Nothing has been submitted or pushed yet.
The repository URL assumes the GitHub account is `Anipixels` and the repository is named as suggested; adjust if not.

| Field | Value |
|---|---|
| Asset Name (title) | Crisp UI Sounds Free - 20 UI Sounds + CrispSfx |
| Category | Scripts |
| Godot version | 4.3 (tested only on 4.7.2 stable (the .NET editor build, run headless on Windows 11); see the note below) |
| Version | 1.0.0 |
| Repository host | GitHub |
| Repository URL | https://github.com/Anipixels/crisp-ui-sounds-free |
| Issues URL | https://github.com/Anipixels/crisp-ui-sounds-free/issues |
| Download Commit | the full 40-character hash of the commit you pushed (`git rev-parse HEAD`) |
| Icon URL | https://raw.githubusercontent.com/Anipixels/crisp-ui-sounds-free/main/icon.png |
| License | CC-BY-4.0 (the form takes one licence; the description says the GDScript is MIT) |
| Suggested repo name | crisp-ui-sounds-free |

Preview: type **Image**, image URL and thumbnail URL both
`https://raw.githubusercontent.com/Anipixels/crisp-ui-sounds-free/main/screenshot.png`

## Short description

(For the GitHub repository "About" line; the Asset Library form has no short-description field.)

20 free UI sounds (clicks, hover, confirm, error, coin, level up...) and a small autoload: CrispSfx.play("click"), with volume, bus and polyphony.

## Description (long)

```
Twenty interface sounds (Ogg Vorbis) and a small autoload that plays them by name:

    CrispSfx.play("click")

Sounds: 2 clicks, hover, pop up / pop down, toggle on / off, confirm, cancel, error, notification, menu open / close,
achievement, level up, coin, gem, purchase, text blip and typing. Loudness-matched, no dead air at the start.

CrispSfx:
- Short names ("click", "coin", "error") or file names ("click_soft_01").
- Polyphony: overlapping sounds do not cut each other off (8 voices by default, adjustable).
- volume_db / set_volume_linear(), bus, muted, optional random pitch per play: CrispSfx.play("coin", 0.05)
- connect_buttons(node): click and hover sounds for every button under a node, in one call.
- add_sound(name, stream) to play your own sounds through it. Keeps playing while the tree is paused.

Enable the plugin (Project Settings > Plugins) to register the CrispSfx autoload. Demo scene: addons/crisp_ui_sounds_free/demo/sounds_demo.tscn
Installs into addons/crisp_ui_sounds_free. GDScript only. Written for Godot 4.3+, tested on 4.7.2.

This is the free sampler of Crisp UI, which has 242 sounds as WAV and OGG (these 20 and 222 more): https://anipixels.itch.io/crisp-ui

Licence: sounds CC BY 4.0 (credit "Crisp UI Sounds Free by Anipixels" with the link above); GDScript MIT.
How it was made: the sounds are synthesised procedurally by code written with an AI assistant (Claude). No AI audio generators.
```

## Notes before you submit

- Godot version: the addon is written for 4.3+, but it has only been run on 4.7.2. Choosing "4.3" in the form is a claim that
  it works there. If you would rather claim only what was tested, pick the newest 4.x entry the form offers instead.
- The `.gitattributes` file marks everything except `addons/` as `export-ignore`, so the zip the Asset Library downloads
  contains only `addons/crisp_ui_sounds_free/` (with its own README and licence copy).
- `LICENSE` holds the CC BY 4.0 notice and link, not the full legal text of the licence (it could not be fetched while building
  this offline). If you want GitHub to detect the licence, replace the body of `LICENSE` with the official text from
  https://creativecommons.org/licenses/by/4.0/legalcode.txt and keep the attribution lines at the top.
