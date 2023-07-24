extends KinematicBody2D

signal did_action
signal died
signal health_update

enum { DIRECTION_LEFT, DIRECTION_RIGHT }

const MAX_HEALTH:int = 200
const JUMP_VELOCITY:float = -800.0

var current_health:int = 200
var move_speed:float = 200.0

var facing_direction:int = DIRECTION_RIGHT

var can_attack:bool = true

var player_active:bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var velocity = Vector2(0.0, 0.0)

func new_level_reset():
	current_health = MAX_HEALTH

func activate():
	can_attack = true
	player_active = true

func deactivate():
	$AttackCooldownTimer.stop()
	$WeaponArmSpriteBack.play("Idle")
	player_active = false

func _physics_process(delta):
	if player_active == true:
		
		
		if not is_on_floor():
			velocity.y += gravity
		
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
			velocity.x = -move_speed
		elif Input.is_action_pressed("move_right"):
			velocity.x = move_speed
		else:
			velocity.x = 0
		
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			emit_signal("did_action", "JUMP", [])
		
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
				
				var enemy_list = []
				# tell the enemies that they have been hit
				for enemy in enemies_hit:
					if enemy is Enemy:
						enemy.do_damage(40)
						enemy_list.append(enemy)
				
				# start the attack cooldown time
				$AttackCooldownTimer.start()
				can_attack = false
				
				emit_signal("did_action", "ATTACK", enemy_list)
		
		move_and_slide(velocity, Vector2.UP)

func do_damage(damage_amount:int):
	current_health -= damage_amount
	emit_signal("health_update", current_health)
	if current_health <= 0:
		emit_signal("died") 

func _on_AttackCooldownTimer_timeout():
	can_attack = true



func _on_WeaponArmSpriteBack_animation_finished():
	$WeaponArmSpriteBack.play("Idle")


func _on_WeaponArmSpriteFront_animation_finished():
	$WeaponArmSpriteFront.play("Idle")
