class_name JobSystemTest
extends UnitTest
tool

signal category_finished()

# Private Members
var job_system: JobSystem

var single_test_data := range(0, 4)
var each_test_data := range(0, 8)
var spread_test_data := range(0, 80)

var comp_single_result := [1, 2, 4, 8]
var comp_each_result := [1, 4, 2, 8, 16, 32, 64, 128]
var comp_spread_result := [
	1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024,
	2048, 4096, 8192, 16384, 32768, 65536, 131072,
	262144, 524288, 1048576, 2097152, 8589934592,
	17179869184, 34359738368, 68719476736, 137438953472,
	274877906944, 549755813888, 1099511627776, 2199023255552,
	4398046511104, 8796093022208, 4194304, 8388608, 16777216,
	33554432, 67108864, 134217728, 268435456, 536870912,
	1073741824, 2147483648, 4294967296, 17592186044416,
	35184372088832, 70368744177664, 140737488355328,
	281474976710656, 562949953421312, 1125899906842624,
	2251799813685248, 4503599627370496, 9007199254740992,
	18014398509481984, 36028797018963968, 72057594037927936,
	144115188075855870, 288230376151711740, 576460752303423490,
	1152921504606847000, 2305843009213694000, 4611686018427387900,
	9223372036854775800
]

func _init().() -> void:
	job_system = JobSystem.new()
	tests = {
		JobSystem.WorkMode.THREADS: [
			single_test_data,
			each_test_data,
			spread_test_data
		],
		JobSystem.WorkMode.COROUTINE: [
			single_test_data,
			each_test_data,
			spread_test_data
		],
		JobSystem.WorkMode.LOOP: [
			single_test_data,
			each_test_data,
			spread_test_data
		]
	}

func run_tests() -> void:
	print('%s running tests...\n' % [get_name()])
	for test_category in tests:
		run_test_category(test_category, tests[test_category])
		yield(self, 'category_finished')
	print('%s all tests passed' % [get_name()])

func run_test_category(work_mode: int, data) -> void:
	print('%s running test category %s...' % [get_name(), JobSystem.WorkMode.keys()[work_mode]])
	job_system.work_mode = work_mode

	print('%s running single test...' % [get_name()])
	job_system.run_job_single(self, 'single_job', {'data': data[0]})
	var single_result = yield(job_system, 'jobs_finished')
	assert(test_result(single_result, comp_single_result))
	print('%s single test passed' % [get_name()])

	print('%s running each test...' % [get_name()])
	job_system.run_jobs_array_each(self, 'each_job', data[1].size(), {'data': data[1]})
	var each_result = yield(job_system, 'jobs_finished')
	assert(test_result(single_result, comp_single_result))
	print('%s each test passed' % [get_name()])

	print('%s running spread test...' % [get_name()])
	job_system.run_jobs_array_spread(self, 'spread_job', data[2].size(), {'data': data[2]})
	var spread_result = yield(job_system, 'jobs_finished')
	assert(test_result(single_result, comp_single_result))
	print('%s spread test passed\n' % [get_name()])

	emit_signal('category_finished')

func single_job(userdata: Dictionary):
	var out_data := []
	for integer in userdata.data:
		out_data.append(pow(2, integer))
	job_system.call_deferred('job_finished', userdata.job_index)
	return out_data

func each_job(userdata: Dictionary):
	job_system.call_deferred('job_finished', userdata.job_index)
	var out_data = userdata.data[userdata.job_index]
	return pow(2, out_data)

func spread_job(userdata: Dictionary):
	var out_data := []
	for i in range(userdata.start, userdata.end):
		out_data.append(pow(2, userdata.data[i]))
	job_system.call_deferred('job_finished', userdata.job_index)
	return out_data

func test_result(result: Array, comp_result: Array) -> bool:
	for i in range(0, result.size()):
		if result[i] != comp_result[i]:
			return false
	return true
