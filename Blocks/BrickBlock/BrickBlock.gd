extends BaseBlock

export (PackedScene) var brick_particles_pack

func hit():
	var new_particles: Node2D = brick_particles_pack.instance()
	$"/root/Main/SpawnedIn".add_child(new_particles)
	new_particles.global_position = global_position
	queue_free()
