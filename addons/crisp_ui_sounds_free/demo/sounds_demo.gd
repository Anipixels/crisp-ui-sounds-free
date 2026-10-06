extends Control
## Crisp UI Sounds Free demo: one button per sound, plus volume, pitch variation and hover-sound switches.

const CrispSfxScript := preload("res://addons/crisp_ui_sounds_free/crisp_sfx.gd")

## The sound player this demo uses: the CrispSfx autoload when there is one, otherwise its own copy.
var sfx: Node
var sound_buttons: Array[Button] = []
var _vary_pitch := false
var _status: Label


func _ready() -> void:
	sfx = get_node_or_null("/root/CrispSfx")
	if sfx == null:
		sfx = CrispSfxScript.new()
		sfx.name = "CrispSfxDemo"
		add_child(sfx)
	_build_ui()


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("1d2233")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)

	var title := Label.new()
	title.text = "Crisp UI Sounds Free  -  20 sounds"
	title.add_theme_font_size_override("font_size", 24)
	column.add_child(title)

	var options := HBoxContainer.new()
	options.add_theme_constant_override("separation", 16)
	column.add_child(options)
	var volume_label := Label.new()
	volume_label.text = "Volume"
	options.add_child(volume_label)
	var volume := HSlider.new()
	volume.min_value = 0.0
	volume.max_value = 1.0
	volume.step = 0.01
	volume.value = sfx.get_volume_linear()
	volume.custom_minimum_size = Vector2(200, 0)
	volume.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	volume.value_changed.connect(_on_volume_changed)
	options.add_child(volume)
	var pitch := CheckBox.new()
	pitch.text = "Random pitch (+-5 %)"
	pitch.toggled.connect(_on_pitch_toggled)
	options.add_child(pitch)
	var stop := Button.new()
	stop.text = "Stop all"
	stop.pressed.connect(sfx.stop_all)
	options.add_child(stop)

	column.add_child(HSeparator.new())

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 8)
	column.add_child(grid)
	for category: String in sfx.CATEGORIES:
		var heading := Label.new()
		heading.text = category
		heading.modulate = Color(1, 1, 1, 0.7)
		grid.add_child(heading)
		var row := HFlowContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(row)
		for sound: StringName in sfx.CATEGORIES[category]:
			var button := Button.new()
			button.text = String(sound)
			button.tooltip_text = 'CrispSfx.play("%s")' % sound
			button.pressed.connect(play_sound.bind(sound))
			row.add_child(button)
			sound_buttons.append(button)

	_status = Label.new()
	_status.text = 'Press a button. In your own code: CrispSfx.play("click")'
	_status.modulate = Color(1, 1, 1, 0.7)
	column.add_child(_status)


## Play one sound the way the buttons do.
func play_sound(sound: StringName) -> AudioStreamPlayer:
	var player: AudioStreamPlayer = sfx.play(sound, 0.05 if _vary_pitch else 0.0)
	_status.text = 'CrispSfx.play("%s"%s)    playing now: %d' % [sound, ", 0.05" if _vary_pitch else "", sfx.get_playing_count()]
	return player


func _on_volume_changed(value: float) -> void:
	sfx.set_volume_linear(value)


func _on_pitch_toggled(on: bool) -> void:
	_vary_pitch = on
