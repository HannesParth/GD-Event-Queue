class_name EventWait
extends Event
## Waits a given number of seconds before continuing queue.


var _wait_time: float;


## Waits [param time] seconds before continuing queue.
func _init(time: float, skippable: bool = false) -> void:
	_wait_time = time;
	is_skippable = skippable;
	super._init();


func _execute(_looping : bool, delta : float) -> Result:
	_wait_time = _wait_time - delta
	
	return Result.FINISHED if _wait_time <= 0 else Result.UNFINISHED
