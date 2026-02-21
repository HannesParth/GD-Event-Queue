@tool
extends EditorPlugin


func _enable_plugin() -> void:
	# Add singleton
	add_autoload_singleton("EventHub", "res://addons/event_hub/scripts/event_hub.gd");


func _disable_plugin() -> void:
	# Remove singleton
	remove_autoload_singleton("EventHub");
