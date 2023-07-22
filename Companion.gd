extends KinematicBody2D

enum { DIRECTION_LEFT, DIRECTION_RIGHT }

var move_speed:float = 150.0

var player

var move_dir = 0

func _process(delta):
	if player:
		var distance_to_player = position.distance_to(player.position)
		if abs(distance_to_player) > 100:
			if distance_to_player < 0:
				move_dir = -1
			else:
				move_dir = 1
		else:
			move_dir = 0

func _physics_process(delta):
	var velocity = Vector2(0.0, 1.0)
	
#	# update the direction the player is facing
#	var mouse_position = get_global_mouse_position()
#	if mouse_position.x <= position.x:
#		if not facing_direction == DIRECTION_LEFT:
#			facing_direction = DIRECTION_LEFT
#			$BodySprite.set_scale(Vector2(-1, 1))
#			$EmptyArmSprite.hide()
#			$WeaponArmSpriteBack.hide()
#			$WeaponArmSpriteFront.show()
#	else:
#		if not facing_direction == DIRECTION_RIGHT:
#			facing_direction = DIRECTION_RIGHT
#			$BodySprite.set_scale(Vector2(1, 1))
#			$EmptyArmSprite.show()
#			$WeaponArmSpriteBack.show()
#			$WeaponArmSpriteFront.hide()
	
	velocity.x = move_dir
	
	move_and_slide(velocity.normalized() * move_speed)
