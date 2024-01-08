class_name OffsetTexture
extends DataTexture
tool

# Public Members
var palette_texture: ImageTexture setget set_palette_texture
var palette_effects: Array setget set_palette_effects

# Private Members

# Setters
func set_palette_texture(new_palette_texture: ImageTexture) -> void:
	if palette_texture != new_palette_texture:
		palette_texture = new_palette_texture
		palette_texture_changed()

func set_palette_effects(new_palette_effects: Array) -> void:
	var changed := false

	if palette_effects.size() != new_palette_effects.size():
		palette_effects.resize(new_palette_effects.size())
		changed = true

	for i in range(0, new_palette_effects.size()):
		if not new_palette_effects[i] is PaletteEffect:
			new_palette_effects[i] = PaletteEffect.new()

		if palette_effects[i] != new_palette_effects[i]:
			palette_effects[i] = new_palette_effects[i]

		changed = true

	if changed:
		palette_effects_changed()

# Getters
func get_default_resource_name() -> String:
	return 'PaletteTexture'

func get_property_list_internal() -> Array:
	return [
		{
			'name': 'palette_texture',
			'type': TYPE_OBJECT,
			'hint': PROPERTY_HINT_RESOURCE_TYPE,
			'hint_string': 'ImageTexture'
		},
		{
			'name': 'palette_effects',
			'type': TYPE_ARRAY,
			'hint': 23,
			'hint_string': "%s:" % [TYPE_OBJECT]
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
func palette_texture_changed() -> void:
	update()

func palette_effects_changed() -> void:
	update()

# Update Functions
func update() -> void:
	gpu_data.clear()

	if not palette_texture:
		full_update()
		return

	if gpu_data.size() != palette_texture.get_height():
		gpu_data.resize(palette_texture.get_height())

	for i in range(0, gpu_data.size()):
		if not gpu_data[i]:
			gpu_data[i] = GPUDataVector2.new()

		if gpu_data[i].get_data_array().size() != palette_texture.get_width():
			gpu_data[i].resize_data(palette_texture.get_width())

	image.fill(Color(0, 0, 0, 0))
	full_update()

# Overrides
func _init().() -> void:
	palette_effects = []

	set_update_mode(UpdateMode.AUTOMATIC)
	set_index_mode(IndexMode.Y_AXIS)

func frame_pre_draw() -> void:
	if not Engine.is_editor_hint():
		for palette_effect in palette_effects:
			if palette_effect.position.y >= gpu_data.size():
				continue

			var data = gpu_data[palette_effect.position.y]

			if palette_effect.position.x >= data.get_data_array().size():
				continue

			data.set_data_by_index(palette_effect.get_delta_offset(), palette_effect.position.x)
	.frame_pre_draw()
