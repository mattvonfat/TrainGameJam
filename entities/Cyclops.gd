extends KinematicBody2D

signal enemy_died

enum { TARGET_ENEMY, TARGET_NONE }

onready var charge_attack_scene = preload("res://ChargeAttack.tscn")

const BASE_ATTACK_DAMAGE:int = 30
const BASE_ATTACK_SPEED:float = 2.0

var enemy_type = "CYCLOPS"

var move_speed:float = 180.0

var max_health:int = 150
var health:int = 150

var move_target
var move_dir = 0
var can_attack:bool = true

var can_charge_attack:bool = true
var charge_attack_build_up:bool = false
var charge_attack_fired:bool = false
var charge_attack_ended:bool = false

func _ready():
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	$ChargeProgress.hide()

func do_damage(damage_amount:int):
	health -= damage_amount
	$HealthBar.value = health
	if health <= 0:
		die()

func _physics_process(delta):
	var velocity = Vector2(0.0, 1.0)
	
	# check if companion is near an enemy
	var left_attack_bodies = $WeaponAreaLeft.get_overlapping_bodies()
	var right_attack_bodies = $WeaponAreaRight.get_overlapping_bodies()
	
	if right_attack_bodies.size() > 0:
		move_target = TARGET_NONE # don't need to move as are in range of enemy
		if can_attack == true:
			$WeaponArmSpriteBack.play("Attack")
			$AttackCooldownTimer.set_wait_time(BASE_ATTACK_SPEED)
			$AttackCooldownTimer.start()
			for enemy in right_attack_bodies:
				enemy.do_damage(BASE_ATTACK_DAMAGE)
			can_attack = false
	
	elif left_attack_bodies.size() > 0:
		move_target = TARGET_NONE # don't need to move as are in range of enemy
		if can_attack == true:
			$WeaponArmSpriteFront.play("Attack")
			$AttackCooldownTimer.set_wait_time(BASE_ATTACK_SPEED)
			$AttackCooldownTimer.start()
			for enemy in left_attack_bodies:
				enemy.do_damage(BASE_ATTACK_DAMAGE)
			can_attack = false
	
	else:
		if can_charge_attack == true:
			do_charge_attack()
		
		elif charge_attack_build_up == true:
			pass
		
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
	
	if move_target == TARGET_ENEMY:
		velocity.x = move_dir
	
	move_and_slide(velocity.normalized() * move_speed)

func _process(delta):
	if charge_attack_build_up == true:
		var time_elapsed = 2.0 - $ChargeUpTime.time_left
		$ChargeProgress.value = time_elapsed

func die():
	emit_signal("enemy_died", enemy_type)
	queue_free()


func _on_AttackCooldownTimer_timeout():
	can_attack = true



func do_charge_attack():
	can_charge_attack = false
	charge_attack_build_up = true
	$ChargeProgress.value = 0
	$ChargeProgress.show()
	$ChargeUpTime.start()

func fire_charge_attack():
	var ca_node = charge_attack_scene.instance()
	add_child(ca_node)
	ca_node.connect("hit_enemy", self, "_on_charge_attack_hit_enemy")
	ca_node.connect("out_of_bounds", self, "_on_charge_attack_out_of_bounds")

func _on_ChargeAttackTimer_timeout():
	can_charge_attack = true

# charge attack has finished charging
func _on_ChargeUpTime_timeout():
	charge_attack_build_up = false
	charge_attack_fired = true
	$ChargeProgress.hide()
	fire_charge_attack()

func _on_charge_attack_hit_enemy(enemy_ref):
	enemy_ref.do_damage(30)
	$ChargeAttackCooldownTimer.start()
	charge_attack_ended = true

func _on_charge_attack_out_of_bounds():
	$ChargeAttackCooldownTimer.start()
	charge_attack_ended = true


func _on_WeaponArmSpriteBack_animation_finished():
	$WeaponArmSpriteBack.play("Idle")


func _on_WeaponArmSpriteFront_animation_finished():
	$WeaponArmSpriteFront.play("Idle")
