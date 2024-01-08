class_name PaletteSine
extends PaletteEffect
tool

var amplitude := Vector2.ONE
var period := Vector2.ONE
var phase_shift := Vector2.ZERO
var vertical_shift := Vector2.ZERO

func _get_default_resource_name() -> String:
	return 'PaletteSine'

func _get_property_list_ex() -> Array:
	return ._get_property_list_ex() + [
		{
			'name': 'amplitude',
			'type': TYPE_VECTOR2
		},
		{
			'name': 'period',
			'type': TYPE_VECTOR2
		},
		{
			'name': 'phase_shift',
			'type': TYPE_VECTOR2
		},
		{
			'name': 'vertical_shift',
			'type': TYPE_VECTOR2
		}
	]

func get_delta_offset() -> Vector2:
	var seconds = OS.get_ticks_msec() * 0.001
	var offset = Vector2.ZERO
	offset.x = amplitude.x * sin(TAU * period.x * (seconds + phase_shift.x)) + vertical_shift.x
	offset.y = amplitude.y * sin(TAU * period.y * (seconds + phase_shift.y)) + vertical_shift.y
	return offset
