extends Node


## just an error message for internal use.
const ERR_QUEUE_NOT_FOUND: String = "Couldn't find event queue of ID [%s]."
## just an error message for internal use.
const ERR_TRY_DELETE_ESSENTIAL: String = (
		"Cannot delete essential event queue. " + 
		"Ff you want to delete this queue, set the queue's is_essential to false."
)
## just an error message for internal use.
const ERR_QUEUE_ID_ALREADY_EXISTS: String = "EventQueue [%s] already exists! Try a different name!";


var main_queue: EventQueue

## Dictionary of current queues, with Key being the ID of a queue.
var _queue_list: Dictionary[String, EventQueue] = {}

## Set to pause/unpause all queues, including the main queue.
var pause_all: bool = false

## does nothing by default.[br]
## set with [Callable] to replace.
## queues event to main_queue if not specified.[br][br]
## MUST return a [bool] (true if event has been queued, false if not).[br]
## takes [Event] variable type as one and only parameter.[br][br]
## example function:
## [codeblock]
## func example_queue_check( new_event : Event ) -> bool:
##     if Global.in_dialogue: # example check.
##         dialogue_queue.queue_event( new_event ); # queues event.
##         return true; # has queue'd event.
##     # has failed check, so has not queue'd event.
##     return false;
## [/codeblock]
var default_queue_check: Callable


func _init() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	default_queue_check = func() -> bool: return false


func _ready() -> void:
	main_queue = EventQueue.new("main_queue", false)
	main_queue.ignore_main_queue = true
	main_queue.is_essential = true


func _process(delta: float) -> void:
	for queue_id: String in _queue_list.keys():
		var event_queue: EventQueue = _queue_list[queue_id]
		if !event_queue.is_running:
			event_queue._execute_next(delta)


func _log_error(msg: String) -> void:
	printerr("[EventHub]: %s" % msg)
	push_error("[EventHub]: %s" % msg)


func add_queue(queue_id: String, event_queue: EventQueue) -> void:
	if _queue_list.has(queue_id):
		_log_error(ERR_QUEUE_ID_ALREADY_EXISTS)
		return
	_queue_list[queue_id] = event_queue


## Queues the [param new_event] into the given [param event_queue]. [br]
## If no queue is given, calls [member EventHub.default_queue_check] to
## check for the default queue to send [param new_event] to. [br]
## If that returns false, meaning the set [member EventHub.default_queue_check]
## found no specific queue for the event, it is added to the main queue.
func queue(new_event: Event, event_queue: EventQueue = null) -> void:
	if event_queue != null:
		event_queue.queue(new_event)
		return
	
	var has_queued_event: bool = default_queue_check.call(new_event)
	if !has_queued_event:
		main_queue.queue(new_event)


func get_queue_by_id(queue_id: String) -> EventQueue:
	if _queue_list.has(queue_id):
		return _queue_list[queue_id]
	
	_log_error(ERR_QUEUE_NOT_FOUND % queue_id)
	return null


## Deletes queue from [member _queue_list], unless [EventQueue].is_essential is true.
func delete_queue(event_queue: EventQueue) -> void:
	if event_queue.is_essential:
		_log_error(ERR_TRY_DELETE_ESSENTIAL)
		return
	
	for queue_id: String in _queue_list.keys():
		if _queue_list[queue_id] == event_queue:
			_queue_list.erase(queue_id)
			break


func delete_queue_by_ID(queue_id: String) -> void:
	if !_queue_list.has(queue_id):
		_log_error(ERR_QUEUE_NOT_FOUND)
		return
	
	var event_queue: EventQueue = _queue_list[queue_id]
	if event_queue.is_essential:
		_log_error(ERR_TRY_DELETE_ESSENTIAL)
		return
	
	event_queue.clear()
	_queue_list.erase(queue_id)
