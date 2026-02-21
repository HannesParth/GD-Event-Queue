class_name TempEventQueue
extends EventQueue

## An [EventQueue] that removes itself after all of its contained events.


var has_had_an_event: bool = false;


func _execute_next(delta: float) -> void:
	can_i_delete_myself_now()
	
	# Checks if any events have populated this queue, at all. 
	# If so, yes. You may delete yourself.
	if _event_queue.size() > 0: 
		has_had_an_event = true
	
	super._execute_next(delta)


func can_i_delete_myself_now() -> void:
	if has_had_an_event and is_empty:
		# I WAS MADE FOR THIIIIIS!!
		EventHub.delete_queue_by_ID(self.id)
