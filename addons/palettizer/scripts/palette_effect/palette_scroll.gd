class_name PaletteScroll
extends PaletteEffect
tool

var scroll_rate: Vector2
var modulo: Vector2

func _get_default_resource_name() -> String:
	return 'PaletteScroll'

func _get_property_list_ex() -> Array:
	return ._get_property_list_ex() + [
		{
			'name': 'scroll_rate',
			'type': TYPE_VECTOR2
		},
		{
			'name': 'modulo',
			'type': TYPE_VECTOR2
		}
	]

func get_delta_offset() -> Vector2:
	var seconds = OS.get_ticks_msec() * 0.001
	var offset = scroll_rate * seconds

	if modulo.x != 0.0:
		offset.x = fposmod(offset.x, modulo.x)

	if modulo.y != 0.0:
		offset.y = fposmod(offset.y, modulo.y)

	return offset
