extends Node2D


func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("restart_scene")):
		GameManager.on_game_restart()
