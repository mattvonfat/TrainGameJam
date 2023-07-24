extends Node2D

func set_result(result:String):
	$Label.set_text(result)

func _on_ContinueButton_pressed():
	GameManager.reset_game()
