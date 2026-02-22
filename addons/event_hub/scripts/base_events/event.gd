@abstract
class_name Event
extends RefCounted
## [color=red]Warning![/color] does nothing by default when instantiated.[br]
## must add [method Event.queue] after/with event eg.
## [codeblock]
## EVENT_Example.new().queue( example_event_queue );
## [/codeblock]
## or:
## [codeblock]
## var event = EVENT_Example.new();
## event.queue( example_event_queue );
## [/codeblock]
## [code]example_event_queue[/code] can be [Null] as well to send to
## default queue, [member EventHub._main_queue].

## return type for [method execute] function.
enum Result { FINISHED, UNFINISHED, ERROR }

## Event name for logging. Equals class_name. Automatically set in _init().
var event_name: String
var current_queue: EventQueue
var is_current_event: bool = false
## by default, [Event]s are skippable as long as they have the method [method Event.on_skip] created.
var is_skippable: bool = true


func _init() -> void:
	var script: Script = get_script()
	event_name = script.get_global_name()


func _log_error(msg: String) -> void:
	printerr("[%s]: %s" % [event_name, msg])
	push_error("[%s]: %s" % [event_name, msg])


## queues self into given [param event_queue].[br]
## if no [param event_queue] is given, sends it to default queue ([member EventHub._main_queue] by default).
func queue(event_queue: EventQueue = null) -> void:
	EventHub.queue(self, event_queue)
	current_queue = event_queue;


## Automatically called by this events [EventQueue]. [br]
## Override to implement your functionality.
@abstract
func _execute(_looping: bool, _delta: float) -> Result


## Optional override for functionality when skipped.
func _on_skip() -> void:
	pass
