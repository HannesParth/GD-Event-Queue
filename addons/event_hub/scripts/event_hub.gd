extends Node


## just an error message for internal use.
const QUEUE_NOT_FOUND_ERR: String = "Couldn't find event queue of ID [%s]."

## just an error message for internal use.
const TRY_DELETE_ESSENTIAL_ERR: String = (
		"Cannot delete essential event queue. " + 
		"Ff you want to delete this queue, set the queue's is_essential to false."
)

## just an error message for internal use.
const QUEUE_ID_ALREADY_EXISTS_ERR: String = "EventQueue [%s] already exists! Try a different name!";


## Set to pause/unpause all queues, including the main queue.
var pause_all: bool = false

## This check is run when an [Event] is queued through [method Event.queue] or
## [method EventHub.queue]. It [b]must[/b] return a [code]bool[/code]. [br]
## [br]
## Takes an [Event] as a parameter and returns whether it has been added to a 
## specific [EventQueue] inside this Callable. [br]
## When it returns [code]false[/code], the event is added to the main queue instead. [br]
## When it returns [code]true[/code], the event has to have been added to a 
## queue in your override of this check. [br]
## [br]
## Always returns [code]false[/code] by default, meaning all events queued without
## a specific [EventQueue] given as a parameter are added to the main queue. [br]
## [br]
## Example:
## [codeblock]
## func example_queue_check(new_event: Event) -> bool:
##     # Example check:
##     if Global.in_dialogue:
##         # Place in specific queue manually:
##         dialogue_queue.queue_event(new_event)
##         return true
## 
##     return false;
## [/codeblock]
var default_queue_check: Callable

## Reference to the main queue.
var _main_queue: EventQueue

## Dictionary of current queues, with Key being the ID of a queue.
var _queue_list: Dictionary[String, EventQueue] = {}


func _init() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	default_queue_check = func() -> bool: return false


func _ready() -> void:
	_main_queue = EventQueue.new("_main_queue", false, true)
	_main_queue.is_essential = true


func _process(delta: float) -> void:
	for queue_id: String in _queue_list.keys():
		var event_queue: EventQueue = _queue_list[queue_id]
		if !event_queue.is_running:
			event_queue._execute_next(delta)


## Adds the given queue by an ID to the hub. [br]
## Returns and logs an error if the queue ID already exists. [br]
## Returns [code]Error.OK[/code] otherwise.
func add_queue(queue_id: String, event_queue: EventQueue) -> Error:
	if _queue_list.has(queue_id):
		_log_error(QUEUE_ID_ALREADY_EXISTS_ERR % queue_id)
		return ERR_ALREADY_EXISTS
	_queue_list[queue_id] = event_queue
	return OK


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
		_main_queue.queue(new_event)


## Returns a registered [EventQueue] instance. [br]
## Logs an error if the given queue ID could not be found. [br] [br]
## Also see [method EventHub.add_queue].
func get_queue_by_id(queue_id: String) -> EventQueue:
	if _queue_list.has(queue_id):
		return _queue_list[queue_id]
	
	_log_error(QUEUE_NOT_FOUND_ERR % queue_id)
	return null


## Deletes a queue from the EventHub, unless it is marked as essential. [br]
## See [member EventQueue.is_essential].
## Returns and logs an error if the queue is essential or could not be found. [br]
## Returns [code]Error.OK[/code] if everything worked.
func delete_queue(event_queue: EventQueue) -> Error:
	if event_queue.is_essential:
		_log_error(TRY_DELETE_ESSENTIAL_ERR)
		return ERR_LOCKED
	
	for queue_id: String in _queue_list.keys():
		if _queue_list[queue_id] == event_queue:
			event_queue.clear()
			_queue_list.erase(queue_id)
			return OK
	
	_log_error(QUEUE_NOT_FOUND_ERR % event_queue.id)
	return ERR_DOES_NOT_EXIST


## Deletes a queue from the EventHub by its ID, unless it is marked as essential. [br]
## See [member EventQueue.is_essential].
## Returns and logs an error if the queue is essential or could not be found. [br]
## Returns [code]Error.OK[/code] if everything worked.
func delete_queue_by_id(queue_id: String) -> Error:
	if !_queue_list.has(queue_id):
		_log_error(QUEUE_NOT_FOUND_ERR % queue_id)
		return ERR_DOES_NOT_EXIST
	
	var event_queue: EventQueue = _queue_list[queue_id]
	if event_queue.is_essential:
		_log_error(TRY_DELETE_ESSENTIAL_ERR)
		return ERR_LOCKED
	
	event_queue.clear()
	_queue_list.erase(queue_id)
	return OK


# Utility function for formatting and posting errors.
func _log_error(msg: String) -> void:
	printerr("[EventHub]: %s" % msg)
	push_error("[EventHub]: %s" % msg)
