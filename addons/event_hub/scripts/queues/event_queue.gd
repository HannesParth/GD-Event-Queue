class_name EventQueue
extends RefCounted
## A queue for events. [br]


## Name / ID of this [EventQueue] Set on instance creation.
var id: String = ""

## Pauses this [EventQueue].
var paused: bool = false

## Whether the current event is being run for more than one [method _process].
var is_looping: bool = false

## Shows whether [Event]s are currently being run in this queue.
var is_running: bool = false

## Cannot be deleted via [method EventHub.delete_queue] if true.
var is_essential: bool = false

## Sets whether queue runs along-side the main queue. [br]
## Settings this to false means this queue is blocked from executing new events
## while the main queue is running.
var ignore_main_queue: bool = false

## Sets whether queue runs while [EventHub] is paused.
var runs_while_pause_all: bool = false

## Checks ran before executing the next event. [br]
## See [method EventQueue.add_update_check].
var extra_checks: Array[Callable] = []

## Determines whether upcoming [Event]s can be skipped or not.
var can_skip: bool = false
## Shows whether [Event]s are currently being skipped.
var is_skipping: bool = false


var _event_queue: Array[Event] = []


func _init(
		queue_id: String, 
		p_runs_while_pause_all: bool = false, 
		p_ignore_main_queue: bool = true
) -> void:
	id = queue_id
	runs_while_pause_all = p_runs_while_pause_all
	ignore_main_queue = p_ignore_main_queue
	EventHub.add_queue(queue_id, self)


## Adds [param event] to the end of the queue. [br]
## Also sets the [Event.current_queue] to this one.
func queue(event: Event) -> void:
	_event_queue.append(event)
	event.current_queue = self


## Returns [code]true[/code] if this queue is empty.
func is_empty() -> bool:
	return _event_queue.is_empty()


## Adds a [Callable] that is checked before allowing this loop to update. [br]
## It must return a [code]bool[/code]. [br]
## This is an AND check. All checks must be true for the queue to update.
func add_update_check(check_func: Callable) -> void:
	extra_checks.append(check_func)


#region Update Checks
func _is_update_allowed() -> bool:
	# When core checks fail, never allow update
	if !_main_queue_allows_update() || !_pause_allows_update():
		return false
	
	# When any extra check fails, do not allow update
	for check: Callable in extra_checks:
		var result: bool = check.call()
		if !result:
			return false
	
	# All check returned green
	return true


func _main_queue_allows_update() -> bool:
	return ignore_main_queue || !EventHub._main_queue.is_running


func _pause_allows_update() -> bool:
	if !paused:
		return true
	
	return runs_while_pause_all || !EventHub.pause_all
#endregion


#region Event Execution
func _execute_next(delta: float) -> void:
	if _event_queue.is_empty():
		is_running = false
		is_skipping = false
		can_skip = false
	
	if !_is_update_allowed(): 
		is_running = false
		return
	
	is_running = true
	var event: Event = _event_queue[0]
	event.is_current_event = true
	
	if _handle_skipping(event):
		return
	
	var event_result: Event.Result = event._execute(is_looping, delta)
	_handle_event_result(event_result, event)


# Returns whether the event has been skipped.
func _handle_skipping(event: Event) -> bool:
	if !is_skipping:
		return false
	
	if !can_skip:
		is_skipping = false
	
	if !event.is_skippable:
		return false
	
	event._on_skip()
	
	remove_top_event(true)
	_schedule_next_event()
	return true


func _handle_event_result(result: Event.Result, event: Event) -> void:
	match result:
		Event.Result.UNFINISHED:
			is_looping = true
			is_running = false
		
		Event.Result.FINISHED:
			is_looping = false
			remove_top_event(true)
			_schedule_next_event()
		
		Event.Result.ERROR:
			_log_error(
				"Event [%s] in queue [%s] encountered an error."
				% [event.event_name, id]
			)
			is_looping = false
			remove_top_event(true)
			_schedule_next_event()
		
		_:
			push_error(
				"Events must return Event.Result!"
			)
			is_looping = false
			remove_top_event(true)
			_schedule_next_event()


func _schedule_next_event() -> void:
	if _event_queue.is_empty():
		is_running = false
		return
	
	_execute_next(EventHub.get_process_delta_time())
#endregion


## Removes the [Event] currently at the top of the queue. [br]
## [param schedule_next]: Whether the next event in the queue is scheduled
## and executed in the same frame.
func remove_top_event(schedule_next: bool) -> void:
	if _event_queue.is_empty():
		return
	
	_event_queue[0].is_current_event = false
	_event_queue.remove_at(0)
	
	if schedule_next:
		_schedule_next_event()


## Removes a given [Event] from this queue.
func remove_event(event: Event) -> void:
	if !_event_queue.has(event):
		return
	
	if event.is_current_event: event.is_current_event = false
	_event_queue.erase(event)


## Begins skipping [Event]s
func toggle_skipping(enable: bool) -> void:
	is_skipping = enable && can_skip


## Clears this event queue.
func clear() -> void:
	for event: Event in _event_queue:
		event.is_current_event = false
	_event_queue.clear()
	is_running = false


## Uses [method @GDScript.is_instance_of] to check whether this queue has an event
## of the given type.
func has_event_type_queued(event_class_type: Variant) -> bool:
	for event: Event in _event_queue:
		if is_instance_of(event, event_class_type):
			return true
	return false


## Deletes this queue from the EventHub, if it is not essential. [br]
## See [method EventHub.delete_queue_by_id].
func delete() -> void:
	EventHub.delete_queue_by_id(id)


# Utility method for formatting and logging errors.
func _log_error(msg: String) -> void:
	printerr("[%s]: %s" % [id, msg])
	push_error("[%s]: %s" % [id, msg])
