class_name IndexTexture
extends ImageTexture
tool

var force_update: bool setget set_force_update
var base_texture: Texture setget set_base_texture
var palette: Resource setget set_palette

var image: Image
var initial_update_count := 2

var job_system: JobSystem

# Setters
func set_force_update(new_force_update: bool) -> void:
	if force_update != new_force_update:
		update_image()

func set_base_texture(new_base_texture: Texture) -> void:
	if base_texture != new_base_texture:
		if base_texture and base_texture.is_connected('changed', self, 'update_image'):
			base_texture.disconnect('changed', self, 'update_image')
		base_texture = new_base_texture
		if base_texture and not base_texture.is_connected('changed', self, 'update_image'):
			base_texture.connect('changed', self, 'update_image')

		base_texture_changed()

func set_palette(new_palette: Resource) -> void:
	if not new_palette is Palette:
		new_palette = Palette.new()

	if palette != new_palette:
		palette = new_palette
		palette_changed()

# Getters
func get_property_list_internal() -> Array:
	return [
		{
			'name': 'force_update',
			'type': TYPE_BOOL
		},
		{
			'name': 'base_texture',
			'type': TYPE_OBJECT,
			'hint': PROPERTY_HINT_RESOURCE_TYPE,
			'hint_string': 'Texture'
		},
		{
			'name': 'palette',
			'type': TYPE_OBJECT,
			'hint': PROPERTY_HINT_RESOURCE_TYPE,
			'hint_string': 'Resource'
		},
		{
			'name': 'image',
			'type': TYPE_OBJECT,
			'hint': PROPERTY_HINT_RESOURCE_TYPE,
			'hint_string': 'Image',
			'usage': PROPERTY_USAGE_NOEDITOR
		}
	]

func get_default_resource_name() -> String:
	return 'IndexTexture'

# Change Handlers
func base_texture_changed() -> void:
	if initial_update_count > 0:
		initial_update_count -= 1
	else:
		update_image()

func palette_changed() -> void:
	if initial_update_count > 0:
		initial_update_count -= 1
	else:
		print('%s palette changed' % [get_name()])
		update_image()

# Update Functions
func update_image() -> void:
	print('%s updating image' % [get_name()])

	if not base_texture or not palette:
		image.create(1, 1, false, Image.FORMAT_L8)
		set_data(image)
		return

	var base_image = base_texture.get_data()
	var base_image_size = base_image.get_size()
	var base_image_format = base_image.get_format()
	if image.get_size() != base_image_size or image.get_format() != base_image_format:
		image.create(base_image_size.x, base_image_size.y, false, base_image_format)
		create_from_image(image, flags | FLAG_VIDEO_SURFACE)

	var base_image_data: PoolByteArray = base_image.get_data()
	job_system.run_jobs_array_spread(self, 'process_subset', base_image_size.x * base_image_size.y, {
		'base_image_size': base_image_size,
		'base_image_data': base_image_data
	})

	var colors := {}
	var unrecognized_colors := {}

	var result = yield(job_system, 'jobs_finished')
	for data in result:
		for position in data.colors:
			colors[position] = data.colors[position]

		for color in data.unrecognized_colors:
			unrecognized_colors[color] = data.unrecognized_colors[color]

	image.fill(Color(0, 0, 0, 0))
	image.lock()
	for position in colors:
		image.set_pixel(position.x, position.y, colors[position])
	image.unlock()

	set_data(image)

	print("%s update complete" % [get_name()])

	for color in unrecognized_colors:
		printerr("%s unrecognized color %s" % [get_name(), color])

func process_subset(userdata: Dictionary) -> Dictionary:
	var out_dict := {
		'colors': {},
		'unrecognized_colors': {}
	}

	for i in range(userdata.start, userdata.end):
		var x = i % int(userdata.base_image_size.x)
		var y = i / userdata.base_image_size.x
		var color_idx = i * 4

		var base_color = Color()
		base_color.r8 = userdata.base_image_data[color_idx]
		base_color.g8 = userdata.base_image_data[color_idx + 1]
		base_color.b8 = userdata.base_image_data[color_idx + 2]
		base_color.a8 = userdata.base_image_data[color_idx + 3]

		if base_color.a8 == 0:
			continue

		var index = -1
		for c in range(0, palette.colors.size()):
			var palette_color = palette.colors[c]
			if base_color.r8 == palette_color.r8 and base_color.g8 == palette_color.g8 and base_color.b8 == palette_color.b8:
				index = c
				break

		if index >= 0:
			var indexed_color = Color(0, 0, 0, 1)
			indexed_color.r8 = index
			out_dict.colors[Vector2(x, y)] = indexed_color
		else:
			out_dict.unrecognized_colors[base_color] = Vector2(x, y)

	job_system.call_deferred('job_finished', userdata.job_index)
	return out_dict

# Overrides
func _init() -> void:
	image = Image.new()
	job_system = JobSystem.new()

	if resource_name == '':
		resource_name = get_default_resource_name()

func _get_property_list() -> Array:
	return get_property_list_internal()
