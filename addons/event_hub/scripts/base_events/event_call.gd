class_name EventCall
extends Event
## Calls given function with optional given variables.


var _call_function: Callable
var _call_vars: Array = []
var _invoke_when_skipped: bool


## calls [param function] with given [param variables] on execute. [br]
## Skippable by default. See [Event.is_skippable]. [br]
## [param invoke_when_skipped]: Whether to invoke the given [Callable] even when 
## this event is skipped.
func _init(function: Callable, invoke_when_skipped: bool, ...variables: Array) -> void:
	_call_function = function
	_call_vars = variables
	_invoke_when_skipped = invoke_when_skipped
	is_skippable = true
	super._init();


func _execute(_looping: bool, _delta: float) -> Result:
	_invoke()
	
	return Result.FINISHED


func _on_skip() -> void:
	if !_invoke_when_skipped:
		return
	
	_invoke()


func _invoke() -> void:
	if !_call_vars.is_empty():
		_call_function.callv(_call_vars)
	else:
		_call_function.call()
