extends MarginContainer

func _on_start_button_button_down() -> void:
	print("PLAY")
	GameManager.on_game_start()



func _on_exit_button_button_down() -> void:
	print("EXIT")
	GameManager.on_exit()
