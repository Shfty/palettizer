class_name PaletteTexture
extends DataTexture
tool

# Public Members
var palettes: Array setget set_palettes

# Private Members
var initial_update: bool

# Setters
func set_palettes(new_palettes: Array) -> void:
	if PRINT:
		print('%s set palettes: %s' % [get_name(), new_palettes])

	if palettes.size() != new_palettes.size():
		palettes.resize(new_palettes.size())
		gpu_data.resize(new_palettes.size())

	for i in range(0, new_palettes.size()):
		LS.disconnect_checked(palettes[i], 'colors_changed', self, 'palette_changed')

		if not gpu_data[i] is GPUDataColor:
			gpu_data[i] = GPUDataColor.new()

		if not new_palettes[i] is Palette:
			palettes[i] = Palette.new()
			palette_changed(i)
		elif palettes[i] != new_palettes[i]:
			palettes[i] = new_palettes[i]
			palette_changed(i)

		LS.connect_checked(palettes[i], 'colors_changed', self, 'palette_changed', [i])

	if initial_update:
		call_deferred('connect_data')
		initial_update = false
	else:
		connect_data()

# Getters
func get_default_resource_name() -> String:
	return 'PaletteTexture'

func get_property_list_internal() -> Array:
	return [
		{
			'name': 'palettes',
			'type': TYPE_ARRAY
		},
		{
			'name': 'gpu_data',
			'type': TYPE_ARRAY,
			'usage': PROPERTY_USAGE_NOEDITOR
		},
		{
			'name': 'image',
			'type': TYPE_OBJECT,
			'hint': PROPERTY_HINT_RESOURCE_TYPE,
			'hint_string': 'Image',
			'usage': PROPERTY_USAGE_NOEDITOR
		}
	]

# Change Handlers
func palette_changed(index: int) -> void:
	if PRINT:
		print('%s palette changed. index: %s' % [get_name(), index])

	if gpu_data[index].get_data_array().size() != palettes[index].colors.size():
		gpu_data[index].resize_data(palettes[index].colors.size(), palettes[index].colors.size() == 0)

	for c in range(0, palettes[index].colors.size()):
		if PRINT:
			print('%s setting data index %s on GPU data %s to %s' % [get_name(), c, index, palettes[index].colors[c]])
		gpu_data[index].set_data_by_index(palettes[index].colors[c], c)

# Overrides
func _init().() -> void:
	initial_update = true
	palettes = []

	set_update_mode(UpdateMode.MANUAL)
	set_index_mode(IndexMode.Y_AXIS)
