# Testing - Crisp UI Sounds Free

Run on 2026-10-06 by `_build/test.py` (kept outside this repository) with

```
$ godot --version
4.7.2.stable.mono.official.ed1daf0bf
```

`godot` below stands for that binary (`Godot_v4.7.2-stable_mono_win64_console.exe`). Every command was run on a fresh copy of the
repository in a temp folder, so the repository itself holds no `.godot/` or `.import` files.
The output shown is complete except for ANSI colour codes and the per-file import progress lines (`[ 42% ] reimport | file`),
which are counted instead. A run fails if any other line of the output contains ERROR, WARNING, "Parse Error", "Failed" or "leaked".

**Not tested:** Godot 4.3 - 4.6 (only 4.7.2 is installed on the build machine), exported builds, and anything that needs eyes or ears
beyond the one rendered screenshot.

## A. The repository opened as a project

The whole repository (what `git clone` gives you), with its own `project.godot`.

### Import

```
$ godot --path . --headless --import
Godot Engine v4.7.2.stable.mono.official.ed1daf0bf - https://godotengine.org
```

Exit code 0. Import progress lines hidden: 93. Lines with ERROR / WARNING / Parse Error / Failed / leaked: 0.

### Test script

```
$ godot --path . --headless --script res://tests/test_addon.gd
Godot Engine v4.7.2.stable.mono.official.ed1daf0bf - https://godotengine.org
RESULT sounds_loaded_and_played=20/20 total_seconds=16.46 aliases=17 demo_buttons_pressed=20 autoload=true bad=[]
```

Exit code 0. Import progress lines hidden: 0. Lines with ERROR / WARNING / Parse Error / Failed / leaked: 0.

## B. Installed into an empty project

Only `addons/` copied into an otherwise empty Godot project (what the Asset Library download installs), plus this repository's `tests/` folder. The empty project has no autoloads, no enabled plugins and no custom settings.

### Import

```
$ godot --path . --headless --import
Godot Engine v4.7.2.stable.mono.official.ed1daf0bf - https://godotengine.org
```

Exit code 0. Import progress lines hidden: 87. Lines with ERROR / WARNING / Parse Error / Failed / leaked: 0.

### Test script

```
$ godot --path . --headless --script res://tests/test_addon.gd
Godot Engine v4.7.2.stable.mono.official.ed1daf0bf - https://godotengine.org
RESULT sounds_loaded_and_played=20/20 total_seconds=16.46 aliases=17 demo_buttons_pressed=20 autoload=false bad=[]
```

Exit code 0. Import progress lines hidden: 0. Lines with ERROR / WARNING / Parse Error / Failed / leaked: 0.

## C. Enabling the plugin registers the autoload

The same empty project, opened in a headless editor with a throwaway helper plugin (not part of this repository) that calls `EditorInterface.set_plugin_enabled()` on Crisp UI Sounds Free, reads the `autoload/CrispSfx` project setting, then disables it again. The helper:

```gdscript
@tool
extends EditorPlugin
# Test helper (not shipped): turns the Crisp UI Sounds Free plugin on and off inside a headless editor
# and prints what happens to the CrispSfx autoload setting.

const TARGET := "res://addons/crisp_ui_sounds_free/plugin.cfg"


func _enter_tree() -> void:
	_run.call_deferred()


func _run() -> void:
	for i in 10:
		await get_tree().process_frame
	var before := ProjectSettings.has_setting("autoload/CrispSfx")
	EditorInterface.set_plugin_enabled(TARGET, true)
	await get_tree().process_frame
	var enabled := EditorInterface.is_plugin_enabled(TARGET)
	var value := str(ProjectSettings.get_setting("autoload/CrispSfx", ""))
	if value.begins_with("*uid://"):  # Godot 4.4+ stores the autoload by UID
		value = "*" + ResourceUID.get_id_path(ResourceUID.text_to_id(value.substr(1)))
	EditorInterface.set_plugin_enabled(TARGET, false)
	await get_tree().process_frame
	var after := ProjectSettings.has_setting("autoload/CrispSfx")
	print("PLUGINCHECK autoload_before=%s plugin_enabled=%s autoload_when_enabled=%s autoload_after_disable=%s" % [before, enabled, value, after])
	get_tree().quit(0 if (not before and enabled and value == "*res://addons/crisp_ui_sounds_free/crisp_sfx.gd" and not after) else 1)
```

### Plugin on / off

```
$ godot --path . --headless --editor --quit-after 2000
Godot Engine v4.7.2.stable.mono.official.ed1daf0bf - https://godotengine.org
PLUGINCHECK autoload_before=false plugin_enabled=true autoload_when_enabled=*res://addons/crisp_ui_sounds_free/crisp_sfx.gd autoload_after_disable=false
```

Exit code 0. Import progress lines hidden: 12. Lines with ERROR / WARNING / Parse Error / Failed / leaked: 0.

## Screenshot

`screenshot.png` is one frame of the demo scene rendered by the same Godot binary in a normal (non-headless) window placed off-screen.
`capture.gd` is a small script written by `_build/test.py` that instantiates the demo scene, waits a few frames and saves the viewport.

```
$ godot --path . --position 6000,6000 --resolution 960x600 --script res://capture.gd
Godot Engine v4.7.2.stable.mono.official.ed1daf0bf - https://godotengine.org
Vulkan 1.4.351 - Forward+ - Using Device #0: NVIDIA - NVIDIA GeForce RTX 4080 SUPER
CAPTURE (960, 600) OK
```

Exit code 0. Saved at 960 x 600. Lines with ERROR / WARNING: 0.

## Result

**PASS** - every command above exited with 0 and printed no errors or warnings.
