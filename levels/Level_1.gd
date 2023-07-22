extends Node2D

signal level_complete

onready var enemies:Array = [
	$Enemy,
	$Enemy2,
	$Enemy3,
	$Boss
]

func _ready():
	for enemy in enemies:
		enemy.connect("enemy_died", self, "_on_enemy_died")
	$Companion.player = $Player

func _on_enemy_died(enemy_type:String):
	print(enemy_type)
	if enemy_type == "BOSS":
		emit_signal("level_complete")
