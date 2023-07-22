extends Node2D

var completed_levels : Array = []

func update_levels(game_day:int, completed_levels:Array):
	$Label.set_text("Day %s" % game_day)
	for level in completed_levels:
		var button = get_node("Level%sButton" % level)
		button.disabled = true

func _on_Level0Button_pressed():
	GameManager.start_level(0)


func _on_Level1Button_pressed():
	GameManager.start_level(1)


func _on_Level2Button_pressed():
	GameManager.start_level(2)
