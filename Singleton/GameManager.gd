extends Node

var game_scene = preload("res://Scenes/BaseLevel/BaseLevel.tscn")
var menu_scene = preload("res://Scenes/MainMenu/main_menu.tscn")

func on_game_start(): 
	get_tree().change_scene_to_packed(game_scene)

func on_game_restart():
	get_tree().reload_current_scene()

func on_exit():
	get_tree().quit()
