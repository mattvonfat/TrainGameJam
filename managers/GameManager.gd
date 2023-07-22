extends Node

onready var main_menu_scene : PackedScene = preload("res://menus/MainMenu.tscn")
onready var level_select_scene : PackedScene = preload("res://menus/LevelSelect.tscn")
onready var game_levels : Array = [
		preload("res://levels/Level_1.tscn"),
		preload("res://levels/Level_1.tscn"),
		preload("res://levels/Level_1.tscn")
	]

onready var player_scene : PackedScene = preload("res://Player.tscn")
onready var companion_scene : PackedScene = preload("res://Companion.tscn")

var main_menu_node
var level_select_node
var game_level_node

var player_node
var companion_node

var game_day : int = 0
var completed_levels : Array = []
var current_level : int


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
	
	player_node = player_scene.instance()
	companion_node = companion_scene.instance()
	companion_node.connect_player(player_node)
	
	# set up the initial game data
	game_day = 1
	level_select_node.update_levels(game_day, completed_levels)

func start_level(level_number:int):
	get_tree().get_root().remove_child(level_select_node)
	
	load_level(level_number)


func load_level(level_number):
	game_level_node = game_levels[level_number].instance()
	game_level_node.connect("level_complete", self, "_on_level_completed")
	get_tree().get_root().add_child(game_level_node)
	game_level_node.set_up(player_node, companion_node)
	current_level = level_number

func return_to_level_select():
	get_tree().get_root().remove_child(game_level_node)
	get_tree().get_root().add_child(level_select_node)
	
	game_level_node.queue_free()
	level_select_node.update_levels(game_day, completed_levels)

func _on_level_completed():
	completed_levels.append(current_level)
	game_day += 1
	
	# if game hits day 4 then it's time for the companion fight, otherwise return to level select
	if game_day == 4:
		print("Companion now fights")
	else:
		return_to_level_select()
