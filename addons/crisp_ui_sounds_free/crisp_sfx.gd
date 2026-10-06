extends Node
## One-line UI sounds. Add this script as an autoload named [code]CrispSfx[/code]
## (enabling the "Crisp UI Sounds Free" plugin does that for you), then:
## [codeblock]
## CrispSfx.play("click")
## CrispSfx.play("coin", 0.05)          # +-5 % random pitch, good for sounds that repeat
## CrispSfx.volume_db = -6.0            # all UI sounds a little quieter
## CrispSfx.bus = &"SFX"                # send them to your own audio bus
## CrispSfx.connect_buttons(self)       # click + hover sounds for every button under this node
## [/codeblock]
## Sounds overlap instead of cutting each other off (up to [member max_polyphony] at once), and they
## keep playing while the tree is paused, so pause menus still click.

const SOUND_DIR := "res://addons/crisp_ui_sounds_free/sounds/"

## The 20 sounds in the pack, by file name (each is SOUND_DIR + name + ".ogg").
const SOUND_NAMES: Array[StringName] = [
	&"click_soft_01",
	&"click_wood_01",
	&"hover_soft_01",
	&"pop_down_01",
	&"pop_up_01",
	&"toggle_off",
	&"toggle_on",
	&"cancel_01",
	&"confirm_01",
	&"error_01",
	&"notification_03",
	&"menu_close",
	&"menu_open",
	&"achievement",
	&"level_up",
	&"coin_ping_01",
	&"gem_01",
	&"purchase",
	&"text_blip_mid_01",
	&"typing_01",
]

## Short names, so calls read well: [code]CrispSfx.play("click")[/code].
const ALIASES := {
	&"click": &"click_soft_01",
	&"click_soft": &"click_soft_01",
	&"click_wood": &"click_wood_01",
	&"hover": &"hover_soft_01",
	&"hover_soft": &"hover_soft_01",
	&"pop_down": &"pop_down_01",
	&"pop_up": &"pop_up_01",
	&"cancel": &"cancel_01",
	&"confirm": &"confirm_01",
	&"error": &"error_01",
	&"notification": &"notification_03",
	&"coin": &"coin_ping_01",
	&"coin_ping": &"coin_ping_01",
	&"gem": &"gem_01",
	&"blip": &"text_blip_mid_01",
	&"text_blip": &"text_blip_mid_01",
	&"typing": &"typing_01",
}

## Sounds grouped the way the pack's folders are (used by the demo scene).
const CATEGORIES := {
	"Buttons": [&"click_soft_01", &"click_wood_01", &"hover_soft_01", &"pop_down_01", &"pop_up_01"],
	"Toggles": [&"toggle_off", &"toggle_on"],
	"Feedback": [&"cancel_01", &"confirm_01", &"error_01"],
	"Notifications": [&"notification_03"],
	"Menus": [&"menu_close", &"menu_open"],
	"Rewards": [&"achievement", &"level_up"],
	"Pickups": [&"coin_ping_01", &"gem_01"],
	"Shop": [&"purchase"],
	"Text": [&"text_blip_mid_01", &"typing_01"],
}

## Volume of every sound played through this node, in decibels (0 = as mixed).
var volume_db: float = 0.0
## Audio bus the sounds go to. A bus name that does not exist falls back to Master.
var bus: StringName = &"Master"
## When true, play() does nothing and returns null.
var muted: bool = false
## How many sounds may overlap. When all voices are busy one of them is cut off and reused.
var max_polyphony: int = 8:
	set(value):
		max_polyphony = maxi(value, 1)
		_trim_players()
## Print a warning when play() is given a name it does not know.
var warn_on_missing: bool = true

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next := 0


func _init() -> void:
	# load(), not preload(): the script then still parses on a project's very first import, before the .ogg files are imported.
	for sound_name in SOUND_NAMES:
		var stream := load(SOUND_DIR + sound_name + ".ogg") as AudioStream
		if stream != null:
			_streams[sound_name] = stream
	process_mode = Node.PROCESS_MODE_ALWAYS


## Play a sound by name (a file name such as "confirm_01" or a short name such as "confirm").
## [param pitch_variation] of 0.05 picks a random pitch between 0.95x and 1.05x.
## [param volume_offset_db] is added to [member volume_db] for this one play.
## Returns the AudioStreamPlayer used, or null if nothing was played.
func play(sound: StringName, pitch_variation: float = 0.0, volume_offset_db: float = 0.0) -> AudioStreamPlayer:
	if muted:
		return null
	var stream := get_stream(sound)
	if stream == null:
		if warn_on_missing:
			push_warning("CrispSfx: no sound named '%s'. Known names: %s" % [sound, ", ".join(get_sound_names())])
		return null
	var player := _free_player()
	player.stream = stream
	player.bus = bus
	player.volume_db = volume_db + volume_offset_db
	player.pitch_scale = 1.0 if pitch_variation <= 0.0 else maxf(randf_range(1.0 - pitch_variation, 1.0 + pitch_variation), 0.01)
	player.play()
	return player


## Stop everything that is playing through this node.
func stop_all() -> void:
	for player in _players:
		player.stop()


## True if play() knows this name (file name, short name or one added with add_sound()).
func has_sound(sound: StringName) -> bool:
	return get_stream(sound) != null


## The AudioStream behind a name, or null.
func get_stream(sound: StringName) -> AudioStream:
	if _streams.has(sound):
		return _streams[sound]
	if ALIASES.has(sound):
		return _streams.get(ALIASES[sound])
	return null


## Every name play() accepts, without the short names, sorted.
func get_sound_names() -> PackedStringArray:
	var names := PackedStringArray()
	for sound_name: StringName in _streams:
		names.append(String(sound_name))
	names.sort()
	return names


## Register your own sound (or replace a built-in one) under [param sound].
func add_sound(sound: StringName, stream: AudioStream) -> void:
	_streams[sound] = stream


## Set the volume from a 0..1 slider value.
func set_volume_linear(value: float) -> void:
	volume_db = linear_to_db(clampf(value, 0.0001, 1.0))


func get_volume_linear() -> float:
	return db_to_linear(volume_db)


## Number of sounds playing right now.
func get_playing_count() -> int:
	var count := 0
	for player in _players:
		if player.playing:
			count += 1
	return count


## Give every button under [param root] a click sound and (optionally) a hover sound.
## Pass an empty name to skip one of them. Buttons added later need another call.
## Returns how many buttons were connected.
func connect_buttons(root: Node, click_sound: StringName = &"click", hover_sound: StringName = &"hover") -> int:
	var count := 0
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		stack.append_array(node.get_children())
		var button := node as BaseButton
		if button == null or button.has_meta(&"crisp_sfx_connected"):
			continue
		button.set_meta(&"crisp_sfx_connected", true)
		if click_sound != &"":
			button.pressed.connect(play.bind(click_sound))
		if hover_sound != &"":
			button.mouse_entered.connect(_on_button_hover.bind(button, hover_sound))
		count += 1
	return count


func _on_button_hover(button: BaseButton, sound: StringName) -> void:
	if not button.disabled:
		play(sound)


func _free_player() -> AudioStreamPlayer:
	for player in _players:
		if not player.playing:
			return player
	if _players.size() < max_polyphony:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)
		return player
	# Everything is busy: take over a voice, going round the pool in turn.
	var taken := _players[_next % _players.size()]
	_next = (_next + 1) % _players.size()
	return taken


func _trim_players() -> void:
	while _players.size() > max_polyphony:
		var player: AudioStreamPlayer = _players.pop_back()
		player.queue_free()
	_next = 0
