class_name ShaderPreprocessorMaterial
extends ShaderMaterial
tool

const IFDEF_TOKEN = '// IFDEF '
const IFNDEF_TOKEN = '// IFNDEF '
const ELSE_TOKEN = '// ELSE'
const ENDIF_TOKEN = '// ENDIF'

var base_shader: Shader setget set_base_shader
var defines: Array setget set_defines

# Setters
func set_base_shader(new_base_shader: Shader) -> void:
	if base_shader != new_base_shader:
		base_shader = new_base_shader
		base_shader_changed()

func set_defines(new_defines: Array) -> void:
	if defines != new_defines:
		defines = new_defines
		defines_changed()

# Getters
func get_default_resource_name() -> String:
	return 'ShaderPreprocessorMaterial'

func get_property_list_internal() -> Array:
	return [
		{
			'name': 'base_shader',
			'type': TYPE_OBJECT,
			'hint': PROPERTY_HINT_RESOURCE_TYPE,
			'hint_string': 'Shader'
		},
		{
			'name': 'defines',
			'type': TYPE_ARRAY,
			'hint': 24,
			'hint_string': "%s:" % [TYPE_STRING]
		}
	]

# Change Handlers
func base_shader_changed() -> void:
	update_shader()

func defines_changed() -> void:
	update_shader()

# Update Functions
func update_shader() -> void:
	if not base_shader:
		set_shader(null)
		return

	var shader_lines = base_shader.code.split('\n')
	var output_lines := PoolStringArray()
	var current_define := ''
	var skip := false
	for i in range(0, shader_lines.size()):
		var shader_line = shader_lines[i]
		var ifdef_pos = shader_line.find(IFDEF_TOKEN)
		var ifndef_pos = shader_line.find(IFNDEF_TOKEN)
		var else_pos = shader_line.find(ELSE_TOKEN)
		var endif_pos = shader_line.find(ENDIF_TOKEN)

		if ifdef_pos != -1:
			current_define = shader_line.substr(ifdef_pos + IFDEF_TOKEN.length(), -1)
			if not current_define in defines:
				skip = true
		elif ifndef_pos != -1:
			current_define = shader_line.substr(ifndef_pos + IFNDEF_TOKEN.length(), -1)
			if current_define in defines:
				skip = true
		elif else_pos != -1:
			skip = !skip
		elif endif_pos != -1:
			skip = false
		elif not skip:
			output_lines.append(shader_line)

	var shader = Shader.new()
	shader.code = output_lines.join('\n')
	set_shader(shader)

# Overrides
func _init().() -> void:
	defines = []

	if resource_name == '':
		resource_name = get_default_resource_name()

func _get_property_list() -> Array:
	return get_property_list_internal()

# Business Logic
func define(name: String) -> void:
	if not name in defines:
		defines.append(name)
		defines_changed()

func undefine(name: String) -> void:
	if name in defines:
		defines.erase(name)
		defines_changed()
