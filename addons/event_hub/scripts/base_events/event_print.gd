class_name EventPrint
extends Event
## Prints out text to the console on execution.


var _print_args: Array
var _execute_when_skipped: bool


## Prints out [param args] as a string to the Output on execution.
func _init(execute_when_skipped: bool, ...args: Array) -> void:
	_execute_when_skipped = execute_when_skipped
	_print_args = args
	
	super._init();


func _execute(_looping: bool, _delta: float) -> Result:
	print.callv(_print_args)
	return Result.FINISHED;


func on_skip() -> void:
	if _execute_when_skipped:
		return
	
	print.callv(_print_args)
