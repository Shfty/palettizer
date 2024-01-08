class_name Palette
extends Resource
tool

signal colors_changed()

# Public Members
var colors: PoolColorArray setget set_colors

# Setters
func set_colors(new_colors: PoolColorArray) -> void:
	if colors != new_colors:
		colors = new_colors
		emit_signal('colors_changed')

# Getters
func get_default_resource_name() -> String:
	return 'Palette'

func get_property_list_internal() -> Array:
	return [
		{
			'name': 'colors',
			'type': TYPE_COLOR_ARRAY
		}
	]

# Overrides
func _init() -> void:
	if resource_name == '':
		resource_name = get_default_resource_name()

func _get_property_list() -> Array:
	return get_property_list_internal()
