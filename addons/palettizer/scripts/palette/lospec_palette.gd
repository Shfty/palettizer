class_name PaletteLospec
extends Palette
tool

const HOST = 'lospec.com'

# Public Members
var reload: bool setget set_reload
var id: String setget set_id
var author: String

# Private Members
var http: HTTPClient

# Setters
func set_reload(new_reload: bool) -> void:
	if reload != new_reload:
		update_palette()

func set_id(new_id: String) -> void:
	if id != new_id:
		id = new_id

# Getters
func get_default_resource_name() -> String:
	return "Lospec Palette"

func get_property_list_internal() -> Array:
	return [
		{
			'name': 'reload',
			'type': TYPE_BOOL
		},
		{
			'name': 'id',
			'type': TYPE_STRING
		},
		{
			'name': 'author',
			'type': TYPE_STRING
		}
	] + .get_property_list_internal()

# Overrides
func _init().() -> void:
	http = HTTPClient.new()

# Business Logic
func update_palette() -> void:
	resource_name = ''
	author = ''
	set_colors(PoolColorArray())
	property_list_changed_notify()

	if id.empty():
		return

	print('Connecting to %s' % [HOST])
	var connect_err = http.connect_to_host(HOST, -1, true)
	if connect_err:
		printerr('Connection error: %s' % [connect_err])
		http.close()
		return

	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		yield(Engine.get_main_loop(), "idle_frame")

	print('Connection successful.')

	var request := '/palette-list/%s.csv' % [id]
	var request_headers := [
		"User-Agent: Pirulo/1.0 (Godot)",
		"Accept: */*"
	]

	print('Requesting %s with headers %s' % [request, request_headers])
	var request_err := http.request(HTTPClient.METHOD_GET, request, request_headers)
	if request_err:
		printerr('Request error: %s' % [request_err])
		http.close()
		return

	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		http.poll()
		yield(Engine.get_main_loop(), "idle_frame")

	if not http.has_response():
		printerr("No HTTP response")
		http.close()
		return

	if http.get_status() != HTTPClient.STATUS_BODY:
		printerr("No response body")
		http.close()
		return

	var rb = PoolByteArray()

	while http.get_status() == HTTPClient.STATUS_BODY:
		http.poll()
		var chunk = http.read_response_body_chunk() # Get a chunk.
		if chunk.size() == 0:
			print("Waiting for response buffer...")
			yield(Engine.get_main_loop(), "idle_frame")
		else:
			rb = rb + chunk

	http.close()

	var csv = rb.get_string_from_ascii()
	var csv_comps = csv.split(',')

	resource_name = csv_comps[0]
	csv_comps.remove(0)

	author = csv_comps[0]
	csv_comps.remove(0)

	var palette_colors = PoolColorArray()
	for comp in csv_comps:
		palette_colors.append(Color(comp))

	print("Request complete.")
	print("Palette name: %s, author: %s, colors: %s" % [resource_name, author, colors])

	set_colors(palette_colors)

	property_list_changed_notify()
