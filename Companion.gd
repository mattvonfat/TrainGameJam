extends KinematicBody2D

enum { DIRECTION_LEFT, DIRECTION_RIGHT }
enum { TARGET_PLAYER, TARGET_ENEMY, TARGET_NONE }

const FOLLOW_DISTANCE:float = 120.0 # how close companion follows player
const ATTACK_RANGE:float = 40.0 # how close companion has to be to attack
const BASE_ATTACK_DAMAGE:int = 10
const BASE_ATTACK_SPEED:float = 3.0# time between attacks

var move_speed:float = 130.0

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


var move_dir = 0

func _ready():
	previous_position_x = position.x

func connect_player(player_ref):
	player = player_ref
	player.connect("did_action", self, "_on_player_did_action")

func new_level_reset():
	move_target = TARGET_PLAYER

func _process(delta):
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
		print("Updated move speed: %s" % move_speed)
	
	if attacks_witnessed >= 6 and has_learnt_attack == false:
		print("can attack")
		has_learnt_attack = true
	
	if companion_attacks_made >= 4:
		companion_attacks_made = 0 # reset counter
		bonus_attack_damage += 5
		bonus_attack_speed += 0.2
		if bonus_attack_speed > 2.7:
			bonus_attack_speed == 2.7

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
				print("attack right")
				$AttackCooldownTimer.set_wait_time(BASE_ATTACK_SPEED - bonus_attack_speed)
				$AttackCooldownTimer.start()
				companion_attacks_made += 1
				for enemy in right_attack_bodies:
					enemy.do_damage(BASE_ATTACK_DAMAGE + bonus_attack_damage)
				can_attack = false
		
		elif left_attack_bodies.size() > 0:
			move_target = TARGET_NONE # don't need to move as are in range of enemy
			if can_attack == true:
				print("attack left")
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


func _on_player_did_action(action_type, args:Array):
	if action_type == "ATTACK":
		attacks_witnessed += 1
		if args.size() == 0:
			random_attacks_witnessed += 1


func _on_AttackCooldownTimer_timeout():
	can_attack = true
