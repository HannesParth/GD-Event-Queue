class_name EventSetVisible
extends Event
## Sets [code]visible[/code] for a given node on execution.


# 2D and 3D nodes have visible property, but both are extentions of different base classes,
# so just going with Node.
var _node: Node
var _set_visible_to: bool
var _execute_when_skipped: bool


## Sets the given Nodes visibility to [param visible] on execution. [br]
## [param execute_when_skipped]: Whether to execute the setting of the visibility
## even when this event is skipped.
func _init(p_node: Node, visible: bool, execute_when_skipped: bool = false) -> void:
	_node = p_node;
	_set_visible_to = visible;
	_execute_when_skipped = execute_when_skipped
	super._init();


func _execute( _looping : bool, _delta : float ) -> Result:
	_node.set("visible", _set_visible_to)
	return Result.FINISHED


func on_skip() -> void:
	if !_execute_when_skipped:
		return
	
	_node.set("visible", _set_visible_to)
