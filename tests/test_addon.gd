extends SceneTree
# Headless check for Crisp UI Sounds Free. Run from the project folder:
#   godot --headless --path . --script res://tests/test_addon.gd
# Loads every sound, exercises the CrispSfx API (autoload if registered, else a fresh instance) and the demo.

const ADDON := "res://addons/crisp_ui_sounds_free/"
const EXPECTED := 20

var _bad: Array[String] = []


func _check(ok: bool, what: String) -> void:
	if not ok:
		_bad.append(what)


func _initialize() -> void:
	var from_autoload := root.has_node("CrispSfx")
	var sfx: Node = root.get_node_or_null("CrispSfx")
	if sfx == null:
		sfx = (load(ADDON + "crisp_sfx.gd") as GDScript).new()
		root.add_child(sfx)
	await process_frame

	# Every sound: loads as Ogg Vorbis, has a length, is not set to loop, and plays.
	var names: PackedStringArray = sfx.get_sound_names()
	_check(names.size() == EXPECTED, "expected %d sounds, got %d" % [EXPECTED, names.size()])
	var loaded := 0
	var seconds := 0.0
	sfx.max_polyphony = 32
	for sound in names:
		var stream := load(ADDON + "sounds/" + sound + ".ogg") as AudioStreamOggVorbis
		_check(stream != null, sound + ": did not load as AudioStreamOggVorbis")
		if stream == null:
			continue
		_check(stream == sfx.get_stream(sound), sound + ": get_stream() mismatch")
		_check(stream.get_length() > 0.02 and stream.get_length() < 5.0, sound + ": odd length %f" % stream.get_length())
		_check(not stream.loop, sound + ": should not loop")
		seconds += stream.get_length()
		var player: AudioStreamPlayer = sfx.play(sound)
		_check(player != null and player.playing and player.stream == stream, sound + ": play() did not start")
		loaded += 1
	_check(sfx.get_playing_count() == EXPECTED, "polyphony: %d of %d voices playing at once" % [sfx.get_playing_count(), EXPECTED])
	sfx.stop_all()
	_check(sfx.get_playing_count() == 0, "stop_all()")

	# Categories cover each sound exactly once; every short name resolves.
	var in_categories := 0
	for category: String in sfx.CATEGORIES:
		for sound: StringName in sfx.CATEGORIES[category]:
			in_categories += 1
			_check(names.has(String(sound)), "category entry %s is not a sound" % sound)
	_check(in_categories == EXPECTED, "categories list %d sounds" % in_categories)
	var aliases := 0
	for alias: StringName in sfx.ALIASES:
		_check(sfx.has_sound(alias), "alias %s does not resolve" % alias)
		aliases += 1
	_check(sfx.get_stream(&"click") == sfx.get_stream(&"click_soft_01"), "click alias")

	# Settings: volume, bus, pitch variation, mute, polyphony limit, unknown names, add_sound.
	sfx.max_polyphony = 3
	sfx.volume_db = -6.0
	sfx.bus = &"Master"
	var voice: AudioStreamPlayer = sfx.play(&"click", 0.0, -3.0)
	_check(voice != null and is_equal_approx(voice.volume_db, -9.0) and voice.bus == &"Master" and is_equal_approx(voice.pitch_scale, 1.0), "volume / bus / pitch defaults")
	voice = sfx.play(&"coin", 0.05)
	_check(voice != null and voice.pitch_scale >= 0.949 and voice.pitch_scale <= 1.051, "pitch variation range")
	for i in 6:
		sfx.play(&"level_up")
	_check(sfx.get_playing_count() == 3, "max_polyphony = 3 gave %d voices" % sfx.get_playing_count())
	sfx.set_volume_linear(0.5)
	_check(is_equal_approx(sfx.get_volume_linear(), 0.5), "set_volume_linear()")
	sfx.muted = true
	_check(sfx.play(&"click") == null, "muted should not play")
	sfx.muted = false
	sfx.warn_on_missing = false
	_check(sfx.play(&"no_such_sound") == null and not sfx.has_sound(&"no_such_sound"), "unknown name should return null")
	sfx.warn_on_missing = true
	sfx.add_sound(&"my_sound", sfx.get_stream(&"gem"))
	_check(sfx.has_sound(&"my_sound") and sfx.play(&"my_sound") != null, "add_sound()")
	sfx.stop_all()
	sfx.volume_db = 0.0
	sfx.max_polyphony = 8

	# connect_buttons(): a pressed button plays the click sound; a second call connects nothing new.
	var box := VBoxContainer.new()
	var button := Button.new()
	box.add_child(button)
	box.add_child(CheckBox.new())
	root.add_child(box)
	_check(sfx.connect_buttons(box) == 2, "connect_buttons() count")
	_check(sfx.connect_buttons(box) == 0, "connect_buttons() should not connect twice")
	button.pressed.emit()
	_check(sfx.get_playing_count() == 1, "connected button did not play")
	button.mouse_entered.emit()
	_check(sfx.get_playing_count() == 2, "hover sound did not play")
	sfx.stop_all()
	box.queue_free()

	# The demo scene: one button per sound; press them all.
	var demo: Control = (load(ADDON + "demo/sounds_demo.tscn") as PackedScene).instantiate()
	root.add_child(demo)
	await process_frame
	_check(demo.sound_buttons.size() == EXPECTED, "demo has %d sound buttons" % demo.sound_buttons.size())
	_check((demo.sfx == sfx) == from_autoload or not from_autoload, "demo should use the autoload when there is one")
	var pressed := 0
	for demo_button: Button in demo.sound_buttons:
		demo_button.pressed.emit()
		pressed += 1
	_check(demo.sfx.get_playing_count() == mini(EXPECTED, demo.sfx.max_polyphony), "demo buttons: %d voices playing" % demo.sfx.get_playing_count())
	await process_frame
	demo.sfx.stop_all()

	# The editor plugin script must at least parse (enabling it is an editor action).
	var plugin := load(ADDON + "plugin.gd") as GDScript
	_check(plugin != null and plugin.can_instantiate(), "plugin.gd did not compile")

	# Godot's audio thread needs a moment to let go of stopped voices; quitting in the same instant makes the
	# engine report leaked objects at exit (it does the same for a bare AudioStreamPlayer).
	await create_timer(0.5).timeout

	print("RESULT sounds_loaded_and_played=%d/%d total_seconds=%.2f aliases=%d demo_buttons_pressed=%d autoload=%s bad=%s" % [
		loaded, EXPECTED, seconds, aliases, pressed, str(from_autoload), str(_bad)])
	quit(0 if _bad.is_empty() and loaded == EXPECTED else 1)
