extends Node2D

signal level_complete

var player
var companion

onready var enemies:Array = [
	$Enemy,
	$Boss
]

func _ready():
	for enemy in enemies:
		enemy.connect("enemy_died", self, "_on_enemy_died")

func set_up(player_node, companion_node):
	player = player_node
	companion = companion_node
	add_child(player_node)
	add_child(companion_node)
	
	player.position = $PlayerStart.position
	companion.position = $CompanionStart.position
	
	player.activate()
	companion.new_level_reset()
	
	player.connect("died", self, "_on_player_died")
	companion.connect("died", self, "_on_companion_died")
	
	$GUI.set_player(player)
	$GUI.set_companion(companion)

func _on_enemy_died(enemy_type:String):
	if enemy_type == "BOSS":
		end_level("WIN")

func _on_player_died():
	end_level("PD")

func _on_companion_died():
	end_level("CD")

func end_level(result):
	companion.health_update()
	player.deactivate()
	remove_child(player)
	remove_child(companion)
	emit_signal("level_complete", result)
