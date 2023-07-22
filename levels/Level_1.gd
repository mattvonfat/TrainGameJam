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
	
	companion.new_level_reset()

func _on_enemy_died(enemy_type:String):
	print(enemy_type)
	if enemy_type == "BOSS":
		remove_child(player)
		remove_child(companion)
		emit_signal("level_complete")
