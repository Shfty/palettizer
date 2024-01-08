class_name ResourceEx
extends Resource

func _get_default_resource_name() -> String:
	return 'ResourceEx'

func _get_property_list_ex() -> Array:
	return []

func _init() -> void:
	if resource_name == '':
		resource_name = _get_default_resource_name()

func _get_property_list() -> Array:
	return _get_property_list_ex()
