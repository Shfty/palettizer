class_name UnitTest
extends Node
tool

export(bool) var run := false setget set_run

var tests: Dictionary

func set_run(new_run: bool) -> void:
	if run != new_run:
		run_tests()

func run_tests() -> void:
	pass
