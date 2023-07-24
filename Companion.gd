extends KinematicBody2D

signal died
signal health_update

enum { DIRECTION_LEFT, DIRECTION_RIGHT }
enum { TARGET_PLAYER, TARGET_ENEMY, TARGET_NONE }
enum { COMPANION_MODE=1, MASTER_MODE }

const FOLLOW_DISTANCE:float = 110.0 # how close companion follows player
const ATTACK_RANGE:float = 20.0 # how close companion has to be to attack
const BASE_ATTACK_DAMAGE:int = 10
const BASE_ATTACK_SPEED:float = 3.0 # time between attacks

const LEFT_VIEW_COMPANION = { "position": Vector2(-56.0, 0.0), "extents": Vector2(80.0, 44.0) }
const RIGHT_VIEW_COMPANION = { "position": Vector2(56.0, 0.0), "extents": Vector2(80.0, 44.0) }
const LEFT_VIEW_MASTER = { "position": Vector2(-426.0, 0.0), "extents": Vector2(450.0, 44.0) }
const RIGHT_VIEW_MASTER = { "position": Vector2(426.0, 0.0), "extents": Vector2(450.0, 44.0) }

var max_health:int = 130
var current_health:int = 130
var move_speed:float = 140.0

var move_target:int = TARGET_PLAYER
var previous_position_x:float = 0.0
var total_move_distance:float = 0.0

var has_learnt_attack:bool = false # does the companion know how to attack
var attacks_witnessed:int = 0 # number of attacks the companion has seen the player do
var random_attacks_witnessed:int = 0 # player attacked without hitting an enemy
var companion_attacks_made:int = 0 # number of attacks the companion has made (only where they hit an enemy)
var bonus_attack_damage:int = 0

var can_attack:bool = true
var bonus_attack_speed:float = 0.0 # a float value which is subtracted from base attack speed

var player

var brain_mode = COMPANION_MODE

var move_dir = 0

func _ready():
	previous_position_x = position.x

func connect_player(player_ref):
	player = player_ref
	player.connect("did_action", self, "_on_player_did_action")

func new_level_reset():
	move_target = TARGET_PLAYER
	current_health = max_health
	$ViewAreaLeft/CollisionShape2D.position = LEFT_VIEW_COMPANION.position
	$ViewAreaLeft/CollisionShape2D.shape.extents = LEFT_VIEW_COMPANION.extents
	$ViewAreaRight/CollisionShape2D.position = RIGHT_VIEW_COMPANION.position
	$ViewAreaRight/CollisionShape2D.shape.extents = RIGHT_VIEW_COMPANION.extents

# called when entering cyclops level so treat like new level reset
func set_master_mode():
	brain_mode == MASTER_MODE
	$ViewAreaLeft/CollisionShape2D.position = LEFT_VIEW_MASTER.position
	$ViewAreaLeft/CollisionShape2D.shape.extents = LEFT_VIEW_MASTER.extents
	$ViewAreaRight/CollisionShape2D.position = RIGHT_VIEW_MASTER.position
	$ViewAreaRight/CollisionShape2D.shape.extents = RIGHT_VIEW_MASTER.extents
	move_target = TARGET_NONE
	current_health = max_health

func _process(delta):
	if brain_mode == COMPANION_MODE:
		companion_brain()
	
	elif brain_mode == MASTER_MODE:
		master_brain()

func companion_brain():
	# work out the direction the companion needs to move if following player
	if move_target == TARGET_PLAYER:
		var distance_to_player = position.distance_to(player.position)
		if distance_to_player > FOLLOW_DISTANCE:
			if position.x < player.position.x:
				move_dir = 1
			else:
				move_dir = -1
		else:
			move_dir = 0
	
	# calculate stat changes
	if total_move_distance >= 100:
		move_speed += 3.0
		total_move_distance = 0
	
	if attacks_witnessed >= 4 and has_learnt_attack == false:
		has_learnt_attack = true
	
	if companion_attacks_made >= 4:
		companion_attacks_made = 0 # reset counter
		bonus_attack_damage += 5
		bonus_attack_speed += 0.2
		if bonus_attack_speed > 2.7:
			bonus_attack_speed == 2.7

func master_brain():
	pass



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

	if has_learnt_attack == true:
		# check if companion is near an enemy
		var left_attack_bodies = $WeaponAreaLeft.get_overlapping_bodies()
		var right_attack_bodies = $WeaponAreaRight.get_overlapping_bodies()
		
		if right_attack_bodies.size() > 0:
			move_target = TARGET_NONE # don't need to move as are in range of enemy
			if can_attack == true:
				$WeaponArmSpriteBack.play("WeaponSwing")
				$AttackCooldownTimer.set_wait_time(BASE_ATTACK_SPEED - bonus_attack_speed)
				$AttackCooldownTimer.start()
				companion_attacks_made += 1
				for enemy in right_attack_bodies:
					enemy.do_damage(BASE_ATTACK_DAMAGE + bonus_attack_damage)
				can_attack = false
		
		elif left_attack_bodies.size() > 0:
			move_target = TARGET_NONE # don't need to move as are in range of enemy
			if can_attack == true:
				$WeaponArmSpriteFront.play("WeaponSwing")
				$AttackCooldownTimer.set_wait_time(BASE_ATTACK_SPEED - bonus_attack_speed)
				$AttackCooldownTimer.start()
				companion_attacks_made += 1
				for enemy in left_attack_bodies:
					enemy.do_damage(BASE_ATTACK_DAMAGE + bonus_attack_damage)
				can_attack = false
		
		else:
			# see if there's an enemy the companion can move to
			var left_view_bodies = $ViewAreaLeft.get_overlapping_bodies()
			var right_view_bodies = $ViewAreaRight.get_overlapping_bodies()

			if right_view_bodies.size() > 0:
				move_target = TARGET_ENEMY
				move_dir = 1
			
			elif left_view_bodies.size() > 0:
				move_target = TARGET_ENEMY
				move_dir = -1
			
			else:
				move_target = TARGET_PLAYER
		
	
	# work out total distance moved
	var change_in_x = abs(position.x - previous_position_x)
	total_move_distance += change_in_x
	previous_position_x = position.x
	
	if move_target == TARGET_PLAYER or move_target == TARGET_ENEMY:
		velocity.x = move_dir
	
	move_and_slide(velocity.normalized() * move_speed)

func health_update():
	var health_difference = max_health - current_health
	max_health = max_health + health_difference
	current_health = max_health

func _on_player_did_action(action_type, args:Array):
	if action_type == "ATTACK":
		attacks_witnessed += 1
		if args.size() == 0:
			random_attacks_witnessed += 1
	
	elif action_type == "JUMP":
		pass

func do_damage(damage_amount:int):
	current_health -= damage_amount
	emit_signal("health_update", current_health)
	if current_health <= 0:
		emit_signal("died")

func _on_AttackCooldownTimer_timeout():
	can_attack = true

func get_companion_stats():
	var stats = {}
	stats["max_health"] = max_health
	stats["move_speed"] = move_speed
	stats["leant_attack"] = has_learnt_attack
	stats["attack_damage"] = BASE_ATTACK_DAMAGE + bonus_attack_damage
	stats["attack_speed"] = BASE_ATTACK_SPEED - bonus_attack_speed
	return stats


func _on_WeaponArmSpriteBack_animation_finished():
	$WeaponArmSpriteBack.play("Idle")


func _on_WeaponArmSpriteFront_animation_finished():
	$WeaponArmSpriteFront.play("Idle")
