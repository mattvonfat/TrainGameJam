extends KinematicBody2D

class_name Enemy

signal enemy_died

enum { DIRECTION_LEFT, DIRECTION_RIGHT }

const BASE_ATTACK_SPEED:float = 1.5
var BASE_ATTACK_DAMAGE:int = 10

var move_speed:float = 200.0

var max_health:int = 100
var health:int = 100

var enemy_type = "NORMAL"

var can_attack:bool = true

func _ready():
	$HealthBar.max_value = max_health
	$HealthBar.value = health

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
		if can_attack == true:
			$AnimatedSprite.play("Bite")
			$AttackCooldownTimer.set_wait_time(BASE_ATTACK_SPEED)
			$AttackCooldownTimer.start()
			for enemy in right_attack_bodies:
				enemy.do_damage(BASE_ATTACK_DAMAGE)
			can_attack = false
	
	elif left_attack_bodies.size() > 0:
		if can_attack == true:
			$AnimatedSprite.play("Bite")
			$AttackCooldownTimer.set_wait_time(BASE_ATTACK_SPEED)
			$AttackCooldownTimer.start()
			for enemy in left_attack_bodies:
				enemy.do_damage(BASE_ATTACK_DAMAGE)
			can_attack = false
	
	else:
		pass
	
	move_and_slide(velocity.normalized() * move_speed)

func die():
	emit_signal("enemy_died", enemy_type)
	queue_free()


func _on_AnimatedSprite_animation_finished():
	$AnimatedSprite.play("Idle")


func _on_AttackCooldownTimer_timeout():
	can_attack = true
