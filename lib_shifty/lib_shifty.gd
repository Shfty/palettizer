class_name LS

## Constants
# Powers of two
const POW_2_8 := int(pow(2, 8))
const POW_2_16 := int(pow(2, 16))
const POW_2_24 := int(pow(2, 24))

# Maximum integer values
const UINT8_MAX = POW_2_8 - 1

# Error string map
const error_strings := {
	FAILED: 'Failed',
	ERR_UNAVAILABLE: 'Unavailable',
	ERR_UNCONFIGURED: 'Unconfigured',
	ERR_UNAUTHORIZED: 'Unauthorized',
	ERR_PARAMETER_RANGE_ERROR: 'Parameter range error.',
	ERR_OUT_OF_MEMORY: 'Out of memory',
	ERR_FILE_NOT_FOUND: 'File not found',
	ERR_FILE_BAD_DRIVE: 'Bad drive',
	ERR_FILE_BAD_PATH: 'Bad path',
	ERR_FILE_NO_PERMISSION: 'No permission',
	ERR_FILE_ALREADY_IN_USE: 'File already in use',
	ERR_FILE_CANT_OPEN: 'Can\'t open file',
	ERR_FILE_CANT_WRITE: 'Can\'t write file',
	ERR_FILE_CANT_READ: 'Can\'t read file',
	ERR_FILE_UNRECOGNIZED: 'File unrecognized',
	ERR_FILE_CORRUPT: 'File corrupt',
	ERR_FILE_MISSING_DEPENDENCIES: 'File missing dependencies',
	ERR_FILE_EOF: 'End of file',
	ERR_CANT_OPEN: 'Can\'t open',
	ERR_CANT_CREATE: 'Can\'t create',
	ERR_QUERY_FAILED: 'Query failed',
	ERR_ALREADY_IN_USE: 'Already in use',
	ERR_LOCKED: 'Locked',
	ERR_TIMEOUT: 'Timeout',
	ERR_CANT_CONNECT: 'Can\'t connect',
	ERR_CANT_RESOLVE: 'Can\'t resolve',
	ERR_CONNECTION_ERROR: 'Connection error',
	ERR_CANT_ACQUIRE_RESOURCE: 'Can\'t acquire resource',
	ERR_CANT_FORK: 'Can\'t fork process',
	ERR_INVALID_DATA: 'Invalid data',
	ERR_INVALID_PARAMETER: 'Invalid parameter',
	ERR_ALREADY_EXISTS: 'Already exists',
	ERR_DOES_NOT_EXIST: 'Does not exist',
	ERR_DATABASE_CANT_READ: 'Database read error',
	ERR_DATABASE_CANT_WRITE: 'Database write error',
	ERR_COMPILATION_FAILED: 'Compilation failed',
	ERR_METHOD_NOT_FOUND: 'Method not found',
	ERR_LINK_FAILED: 'Link failed',
	ERR_SCRIPT_FAILED: 'Script failed',
	ERR_CYCLIC_LINK: 'Cyclic link',
	ERR_INVALID_DECLARATION: 'Invalid declaration',
	ERR_DUPLICATE_SYMBOL: 'Duplicate symbol',
	ERR_PARSE_ERROR: 'Parse error',
	ERR_BUSY: 'Busy',
	ERR_SKIP: 'Skip',
	ERR_HELP: 'Help',
	ERR_BUG: 'Bug',
	ERR_PRINTER_ON_FIRE: 'Printer on fire'
}

## Integer Packing Functions

# Packs a 32-bit integer into 4 8-bit bytes
static func pack_uint_32_pool_byte_array(uint32: int) -> PoolByteArray:
	return PoolByteArray([
		uint32 % POW_2_8,
		(uint32 / POW_2_8) % POW_2_8,
		(uint32 / POW_2_16) % POW_2_8,
		(uint32 / POW_2_24) % POW_2_8
	])

# Packs a 32-bit integer into RGBA8 color components
static func pack_uint_32_color_rgba8(uint32: int) -> Color:
	var color = Color()
	color.r8 = uint32 % POW_2_8
	color.g8 = (uint32 / POW_2_8) % POW_2_8
	color.b8 = (uint32 / POW_2_16) % POW_2_8
	color.a8 = (uint32 / POW_2_24) % POW_2_8
	return color

# Unpacks 4 8-bit-bytes into a 32-bit integer
static func unpack_pool_int_array_uint_32(pool_int_array: PoolByteArray) -> int:
	return int(
		pool_int_array[0] * UINT8_MAX +
		pool_int_array[1] * UINT8_MAX * POW_2_8 +
		pool_int_array[2] * UINT8_MAX * POW_2_16 +
		pool_int_array[3] * UINT8_MAX * POW_2_24
	)

# Unpacks RGBA8 color components into a 32-bit integer
static func unpack_color_rgba8_uint_32(rgba8: Color) -> int:
	return int(
		rgba8.r * UINT8_MAX +
		rgba8.g * UINT8_MAX * POW_2_8 +
		rgba8.b * UINT8_MAX * POW_2_16 +
		rgba8.a * UINT8_MAX * POW_2_24
	)

# Error string lookup
static func get_error_string(error: int) -> String:
	assert(error != OK)
	return error_strings[error] if error in error_strings else ''

# Error-checked signal disconnection
static func disconnect_checked(from_object: Object, from_signal: String, to_object: Object, to_method: String) -> void:
	if from_object and from_object.is_connected(from_signal, to_object, to_method):
		from_object.disconnect(from_signal, to_object, to_method)

# Error-checked signal connection
static func connect_checked(from_object: Object, from_signal: String, to_object: Object, to_method: String, binds: Array = []) -> void:
	if from_object and not from_object.is_connected(from_signal, to_object, to_method):
		from_object.connect(from_signal, to_object, to_method, binds)
