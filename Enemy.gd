extends KinematicBody2D

class_name Enemy

signal enemy_died

enum { DIRECTION_LEFT, DIRECTION_RIGHT }

var move_speed:float = 200.0

var health:int = 100

var enemy_type = "NORMAL"

func do_damage(damage_amount:int):
	health -= damage_amount
	print(health)
	if health <= 0:
		die()

func _physics_process(delta):
	var velocity = Vector2(0.0, 1.0)
	
	move_and_slide(velocity.normalized() * move_speed)

func die():
	emit_signal("enemy_died", enemy_type)
	queue_free()
