class_name LinkedEventQueue
extends EventQueue
## An [EventQueue] linked to a node. Removes itself when the reference to the
## linked node is lost.

var link: Node


func _init(
		queue_name: String, 
		linked_node: Node, 
		p_runs_while_pause_all: bool = false,  
		p_ignore_main_queue: bool = false
) -> void:
	link = linked_node
	super._init(queue_name, p_runs_while_pause_all, p_ignore_main_queue)


func _execute_next(delta: float) -> void:
	if is_essential:
		_log_error("LinkedEventQueue cannot be essential! Use EventQueue instead!");
		is_essential = false
		return
	
	if link == null:
		EventHub.delete_queue_by_ID(self.id)
		return;
	
	super._execute_next(delta);
