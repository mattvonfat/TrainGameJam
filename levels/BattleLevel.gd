extends Node2D

signal level_complete

var companion

onready var enemies:Array = [
	$Cyclops
]

func _ready():
	for enemy in enemies:
		enemy.connect("enemy_died", self, "_on_enemy_died")

func set_up(companion_node):
	companion = companion_node
	add_child(companion_node)
	
	companion.position = $CompanionStart.position
	companion.set_master_mode()
	
	companion.connect("died", self, "_on_companion_died")
	$GUI.set_companion(companion)
	$GUI.hide_player()

func _on_enemy_died(enemy_type:String):
	end_level("WON")

func _on_companion_died():
	end_level("LOST")

func end_level(result:String):
	remove_child(companion)
	emit_signal("level_complete", result)
