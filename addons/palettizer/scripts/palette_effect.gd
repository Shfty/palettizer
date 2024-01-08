class_name PaletteEffect
extends ResourceEx
tool

# Public Members
var position: Vector2

# Getters
func get_delta_offset() -> Vector2:
	return Vector2.ZERO

# Overrides
func _get_default_resource_name() -> String:
	return 'PaletteEffect'

func _get_property_list_ex() -> Array:
	return [
		{
			'name': 'position',
			'type': TYPE_VECTOR2
		}
	]
