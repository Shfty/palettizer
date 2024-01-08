class_name JobSystem
tool

### GDScript job system
# Runs functions with the signature job(userdata: Dictionary) -> Variant in a configurable manner,
# then collates and returns their results to the caller via signal

## Signals
signal jobs_finished(results)

## Enums
enum WorkMode {
	THREADS = 0,
	COROUTINE = 1,
	LOOP = 2
}

## Public Members
var work_mode = WorkMode.THREADS

## Private Members
var job_count := -1
var job_results: Dictionary
var threads: Array

## Overrides
func _init() -> void:
	job_results = {}
	threads = []

## Business Logic
# Reset the job system's internal state
func _reset_state() -> void:
	threads.clear()
	job_count = -1
	job_results.clear()

# Run a single job
func run_job_single(instance: Object, function: String, userdata: Dictionary) -> void:
	if job_count != -1:
		printerr("Previous jobs still running")
		return

	_reset_state()

	job_count = 1

	var userdata_copy = userdata.duplicate()
	userdata_copy['job_index'] = 0

	match work_mode:
		WorkMode.THREADS:
			var thread = Thread.new()
			threads.append(thread)
			var thread_start_error = thread.start(instance, function, userdata_copy)
			if thread_start_error:
				printerr("Thread start error: %s" % [LS.get_error_string(thread_start_error)])
				return
		WorkMode.COROUTINE:
			job_results[0] = instance.call(function, userdata_copy)
			yield(Engine.get_main_loop().create_timer(0.0), 'timeout')
		WorkMode.LOOP:
			job_results[0] = instance.call(function, userdata_copy)

# Run one job for each element of an array
func run_jobs_array_each(instance: Object, function: String, size: int, userdata: Dictionary) -> void:
	if job_count != -1:
		printerr("Previous jobs still running")
		return

	_reset_state()

	job_count = size

	var iter = range(0, job_count)
	for i in iter:
		var userdata_copy = userdata.duplicate()
		userdata_copy['job_index'] = i

		match work_mode:
			WorkMode.THREADS:
				var thread = Thread.new()
				threads.append(thread)
				thread.start(instance, function, userdata_copy)
			WorkMode.COROUTINE:
				job_results[i] = instance.call(function, userdata_copy)
				yield(Engine.get_main_loop().create_timer(0.0), 'timeout')
			WorkMode.LOOP:
				job_results[i] = instance.call(function, userdata_copy)

# Run one job for each chunk of an array, with chunk size being determined by OS thread count
func run_jobs_array_spread(instance: Object, function: String, size: int, userdata: Dictionary) -> void:
	if job_count != -1:
		printerr("Previous jobs still running")
		return

	_reset_state()

	job_count = OS.get_processor_count() - 1
	var chunk_size = size / job_count

	var iter = range(0, job_count)
	for i in iter:
		var userdata_copy = userdata.duplicate()
		userdata_copy['job_index'] = i
		userdata_copy['start'] = i * chunk_size

		if i == iter[-1]:
			userdata_copy['end'] = size
		else:
			userdata_copy['end'] = i * chunk_size + chunk_size

		match work_mode:
			WorkMode.THREADS:
				var thread = Thread.new()
				threads.append(thread)
				thread.start(instance, function, userdata_copy)
			WorkMode.COROUTINE:
				job_results[i] = instance.call(function, userdata_copy)
				yield(Engine.get_main_loop().create_timer(0.0), 'timeout')
			WorkMode.LOOP:
				job_results[i] = instance.call(function, userdata_copy)

# Job finish notification - must be invoked through call_deferred by job methods before they return
func job_finished(index: int) -> void:
	if work_mode == WorkMode.THREADS:
		job_results[index] = threads[index].wait_to_finish()

	job_count -= 1
	if job_count == 0:
		var result_array := []
		for key in job_results:
			var value = job_results[key]
			if value is Array:
				result_array += value
			else:
				result_array.append(value)
		_reset_state()
		emit_signal('jobs_finished', result_array)
