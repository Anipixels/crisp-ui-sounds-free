@tool
extends EditorPlugin
## Registers the CrispSfx autoload when the plugin is enabled and removes it when it is disabled.

const AUTOLOAD_NAME := "CrispSfx"
const AUTOLOAD_PATH := "res://addons/crisp_ui_sounds_free/crisp_sfx.gd"


func _enable_plugin() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)


func _disable_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)
