extends KinematicBody2D

signal hit_enemy
signal out_of_bounds

var dir = -1.0
var move_speed = 2.0

func _physics_process(delta):
	if global_position.x < -100:
		emit_signal("out_of_bounds")
		queue_free()
	
	var velocity = Vector2(move_speed * dir, 0)
	move_and_collide(velocity)

func _on_HitBox_body_entered(body):
	emit_signal("hit_enemy", body)
	queue_free()
