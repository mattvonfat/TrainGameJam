extends Node2D

var sprite_rotation:float = PI/2

func _on_Timer_timeout():
	sprite_rotation -= 2*PI / 40
	$Sprite.set_rotation(sprite_rotation)
	
	if sprite_rotation <= PI/2 - 2*PI:
		$Timer.stop()
		GameManager.skip_animation_ended()
