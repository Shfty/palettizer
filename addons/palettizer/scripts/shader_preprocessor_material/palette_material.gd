class_name PaletteMaterial
extends ShaderPreprocessorMaterial
tool

# Constants
const DEBUG := true

# Public Members
var explicit_index_texture := false setget set_explicit_index_texture
var visualize_indices := false setget set_visualize_indices
var offset := Vector2.ZERO setget set_offset
var palette_effect: Resource setget set_palette_effect
var palette_texture setget set_palette_texture
var offset_texture setget set_offset_texture

# Setters
func set_explicit_index_texture(new_explicit_index_texture: bool) -> void:
	if explicit_index_texture != new_explicit_index_texture:
		explicit_index_texture = new_explicit_index_texture
		explicit_index_texture_changed()

func set_visualize_indices(new_visualize_indices: bool) -> void:
	if visualize_indices != new_visualize_indices:
		visualize_indices = new_visualize_indices
		visualize_indices_changed()

func set_offset(new_offset: Vector2) -> void:
	if offset != new_offset:
		offset = new_offset
		set_shader_param('offset', offset)

func set_palette_effect(new_palette_effect: Resource) -> void:
	if not new_palette_effect is PaletteEffect:
		new_palette_effect = PaletteEffect.new()

	if palette_effect != new_palette_effect:
		palette_effect = new_palette_effect

func set_palette_texture(new_palette_texture: ImageTexture) -> void:
	if palette_texture != new_palette_texture:
		palette_texture = new_palette_texture
		set_shader_param('palette_texture', palette_texture)

func set_offset_texture(new_offset_texture: ImageTexture) -> void:
	if offset_texture != new_offset_texture:
		offset_texture = new_offset_texture
		set_shader_param('offset_texture', offset_texture)

# Getters
func get_default_resource_name() -> String:
	return 'PaletteMaterial'

func get_property_list_internal() -> Array:
	var property_list = []

	property_list += [
		{
			'name': 'Palette',
			'type': TYPE_STRING,
			'usage': PROPERTY_USAGE_GROUP
		},
		{
			'name': 'offset',
			'type': TYPE_VECTOR2
		},
		{
			'name': 'palette_effect',
			'type': TYPE_OBJECT,
			'hint': PROPERTY_HINT_RESOURCE_TYPE,
			'hint_string': 'Resource'
		},
		{
			'name': 'visualize_indices',
			'type': TYPE_BOOL
		},
		{
			'name': 'Textures',
			'type': TYPE_STRING,
			'usage': PROPERTY_USAGE_GROUP
		},
		{
			'name': 'explicit_index_texture',
			'type': TYPE_BOOL
		}
	]

	if explicit_index_texture:
		property_list += [
			{
				'name': 'index_texture',
				'type': TYPE_OBJECT,
				'hint': PROPERTY_HINT_RESOURCE_TYPE,
				'hint_string': 'ImageTexture'
			}
		]

	property_list += [
		{
			'name': 'palette_texture',
			'type': TYPE_OBJECT,
			'hint': PROPERTY_HINT_RESOURCE_TYPE,
			'hint_string': 'ImageTexture'
		},
		{
			'name': 'offset_texture',
			'type': TYPE_OBJECT,
			'hint': PROPERTY_HINT_RESOURCE_TYPE,
			'hint_string': 'ImageTexture'
		}
	]

	if DEBUG:
		property_list += [
			{
				'name': 'Debug',
				'type': TYPE_STRING,
				'usage': PROPERTY_USAGE_GROUP
			},
			{
				'name': 'base_shader',
				'type': TYPE_OBJECT,
				'hint': PROPERTY_HINT_RESOURCE_TYPE,
				'hint_string': 'Shader'
			}
		]

	return property_list

# Change Handlers
func explicit_index_texture_changed() -> void:
	if explicit_index_texture:
		define('EXPLICIT_INDEX_TEXTURE')
	else:
		undefine('EXPLICIT_INDEX_TEXTURE')
	property_list_changed_notify()

func visualize_indices_changed() -> void:
	if visualize_indices:
		define('VISUALIZE_INDICES')
	else:
		undefine('VISUALIZE_INDICES')

# Overrides
func _init().() -> void:
	LS.connect_checked(VisualServer, 'frame_pre_draw', self, 'frame_pre_draw')

func frame_pre_draw() -> void:
	if palette_effect and not Engine.is_editor_hint():
		set_shader_param('offset', offset + palette_effect.get_delta_offset())
