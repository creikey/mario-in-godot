extends KinematicBody2D

class_name BaseBlock

export (PackedScene) var goody_pack

var has_goody: bool = true

func hit():
	if not has_goody:
		return
	if goody_pack != null:
		has_goody = false
		var new_goody: Node2D = goody_pack.instance()
		add_child(new_goody)
		new_goody.global_position = $CollisionShape2D.global_position
	$AnimationPlayer.play("hit")
