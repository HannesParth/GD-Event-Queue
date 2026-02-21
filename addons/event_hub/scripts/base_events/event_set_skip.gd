class_name EventSetSkip
extends Event
## Sets whether upcoming events can be skipped or not.


var _set_skip_to: bool


func _init(set_to: bool) -> void:
	_set_skip_to = set_to
	super._init();


func _execute( _looping : bool, _delta : float ) -> Result:
	current_queue.can_skip = _set_skip_to;
	
	if !_set_skip_to && current_queue.is_skipping:
		current_queue.is_skipping = false;
	
	return Result.FINISHED;
