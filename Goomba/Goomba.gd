extends KinematicBody2D

const gravity_accel: float = 2500.0
const move_speed: float = 120.0

var velocity := Vector2(-move_speed, 0)

# fulfills jump_killable
func get_collision_center() -> Vector2:
	return $CollisionCenter.global_position
func kill():
	$AnimationPlayer.play("die")

func _physics_process(delta):
	if $AnimationPlayer.current_animation == "die":
		return
	if is_on_wall():
		velocity.x *= -1.0

	velocity.y += gravity_accel * delta
	
	var adjusted_vel: Vector2 = move_and_slide(velocity, Vector2(0, -1))
	velocity.y = adjusted_vel.y
	for c in get_slide_count():
		var collision: KinematicCollision2D = get_slide_collision(c)
		if collision.collider.is_in_group("players"):
			collision.collider.kill()
