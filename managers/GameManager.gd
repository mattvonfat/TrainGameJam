extends Node

onready var main_menu_scene : PackedScene = preload("res://menus/MainMenu.tscn")
onready var level_select_scene : PackedScene = preload("res://menus/LevelSelect.tscn")
onready var Level_1 : PackedScene = preload("res://levels/Level_1.tscn")

var main_menu_node
var level_select_node
var game_level_node

func splash_to_menu():
	var splash_screen = get_tree().get_root().get_node("SplashScreen")
	get_tree().get_root().remove_child(splash_screen)
	splash_screen.queue_free()
	
	start_main_menu()

func start_main_menu():
	main_menu_node = main_menu_scene.instance()
	#controls_menu_node = controls_menu_scene.instance()
	
	get_tree().get_root().add_child(main_menu_node)

func start_new_game():
	level_select_node = level_select_scene.instance()
	
	get_tree().get_root().remove_child(main_menu_node)
	get_tree().get_root().add_child(level_select_node)
	
	main_menu_node.queue_free()

func start_level(level_number:int):
	get_tree().get_root().remove_child(level_select_node)
	
	load_level(level_number)



func load_level(level_number):
	game_level_node = Level_1.instance()
	game_level_node.connect("level_complete", self, "_on_level_completed")
	get_tree().get_root().add_child(game_level_node)

func return_to_level_select():
	get_tree().get_root().remove_child(game_level_node)
	get_tree().get_root().add_child(level_select_node)
	
	game_level_node.queue_free()

func _on_level_completed():
	return_to_level_select()
