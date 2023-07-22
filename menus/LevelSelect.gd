extends Node2D

var completed_levels : Array = []

func update_levels():
	pass

func _on_Level1Button_pressed():
	GameManager.start_level(1)
