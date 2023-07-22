extends KinematicBody2D

enum { DIRECTION_LEFT, DIRECTION_RIGHT }

var move_speed:float = 200.0

var facing_direction:int = DIRECTION_RIGHT

var can_attack:bool = true

func _physics_process(delta):
	var velocity = Vector2(0.0, 1.0)
	
	# update the direction the player is facing
	var mouse_position = get_global_mouse_position()
	if mouse_position.x <= position.x:
		if not facing_direction == DIRECTION_LEFT:
			facing_direction = DIRECTION_LEFT
			$BodySprite.set_scale(Vector2(-1, 1))
			$EmptyArmSprite.hide()
			$WeaponArmSpriteBack.hide()
			$WeaponArmSpriteFront.show()
	else:
		if not facing_direction == DIRECTION_RIGHT:
			facing_direction = DIRECTION_RIGHT
			$BodySprite.set_scale(Vector2(1, 1))
			$EmptyArmSprite.show()
			$WeaponArmSpriteBack.show()
			$WeaponArmSpriteFront.hide()
	
	if Input.is_action_pressed("move_left"):
		velocity.x += -1
	
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	
	if Input.is_action_pressed("attack_1"):
		# check attacking isn't on cooldown
		if can_attack == true:
			# do attack animation
			if facing_direction == DIRECTION_LEFT:
				$WeaponArmSpriteFront.play("WeaponSwing")
			else:
				$WeaponArmSpriteBack.play("WeaponSwing")
			
			# get the enemies hit by the attack - check weapon area for direction facing
			var enemies_hit
			if facing_direction == DIRECTION_LEFT:
				enemies_hit = $WeaponAreaLeft.get_overlapping_bodies()
			else:
				enemies_hit = $WeaponAreaRight.get_overlapping_bodies()
			
			# tell the enemies that they have been hit
			for enemy in enemies_hit:
				if enemy is Enemy:
					enemy.do_damage(40)
			
			# start the attack cooldown time
			$AttackCooldownTimer.start()
			can_attack = false
	
	move_and_slide(velocity.normalized() * move_speed)


func _on_AttackCooldownTimer_timeout():
	can_attack = true



func _on_WeaponArmSpriteBack_animation_finished():
	$WeaponArmSpriteBack.play("Idle")


func _on_WeaponArmSpriteFront_animation_finished():
	$WeaponArmSpriteFront.play("Idle")
