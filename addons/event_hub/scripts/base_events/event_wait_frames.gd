class_name EventWaitFrames
extends Event
## Suspends queue for a given number of frames.


var _frames_passed: int = 0
var _frames_to_wait: int


## Waits [param frames_to_wait] frames before continuing queue.
func _init(frames_to_wait: int = 1, skippable: bool = false ) -> void:
	_frames_to_wait = frames_to_wait
	RenderingServer.frame_post_draw.connect(updated_frame)
	is_skippable = skippable
	
	super._init();


func _execute(_looping: bool, _delta: float) -> Result:
	if _frames_passed >= _frames_to_wait:
		return Result.FINISHED
	return Result.UNFINISHED


func updated_frame() -> void:
	if is_current_event:
		_frames_passed += 1
