class_name EventWaitForInput
extends Event
## Waits for user input of a given action. See [InputMap].


var _action: String
var _is_action_valid: bool = true


## Suspends queue until [param action] is pressed. [br]
## Pass an empty String to accept any action. [br]
## Passing a String that is not part of the Input Map will trigger an error.
func _init( action : StringName = "" ) -> void:
	if !_action.is_empty() && !InputMap.has_action(_action):
		_log_error("The given input action [%s] was not found in the Input Map!" % _action)
		_is_action_valid = false
	
	_action = action;
	super._init();


func _execute(looping: bool, _delta: float) -> Result:
	if _is_action_valid:
		return Result.ERROR
	
	if !looping:
		return Result.UNFINISHED
	
	var input_received: bool = false
	
	if _action.is_empty():
		input_received = Input.is_anything_pressed()
	else:
		input_received = Input.is_action_just_pressed(_action)
	
	return Result.FINISHED if input_received else Result.UNFINISHED
