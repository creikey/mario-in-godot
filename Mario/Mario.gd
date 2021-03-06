extends KinematicBody2D

signal dead

const gravity_accel: float = 2500.0

const jump_gravity_accel: float = 1300.0
const jump_velocity: float = 800.0

const walking_drag: float = 500.0
const walking_accel: float = walking_drag + 500.0
const sprinting_accel: float = walking_accel*2.0
const max_horizontal_velocity: float = 400.0
const sprinting_max_horizontal_velocity: float = 700.0

const jump_kill_tolerance: float = 0.6 # the closer to 1.0, the more "on top" of the enemy the jump kill must be
const jump_kill_velocity: float = 500.0

const die_jump_up_velocity: float = 900.0

var coins: int = 0
var velocity := Vector2()
var _dying: bool = false

onready var _player: MultiPlayer = $MultiPlayer
onready var _anim: AnimationPlayer = $AnimationPlayer
onready var _sprite: Sprite = $Sprite
onready var _default_anim_speed: float = _anim.playback_speed

# fullfills players
func kill():
	if _dying:
		return
	$CollisionShape2D.disabled = true
	velocity.y = -die_jump_up_velocity
	z_index = 5
	_anim.play("die")
	_dying = true
	velocity.x = 0.0
	$DeathSoundPlayer.play()

func reset():
	velocity = Vector2()
	_dying = false
	$CollisionShape2D.disabled = false
	$Camera2D.reset_smoothing()

func _physics_process(delta):
	# vertical movement
	if is_on_floor() and Input.is_action_just_pressed("g_jump"):
		velocity.y = -jump_velocity
		_player.play(preload("res://sounds/Jump.wav"))
	var effective_gravity: float = gravity_accel
	if velocity.y < 0.0 and Input.is_action_pressed("g_jump"):
		effective_gravity = jump_gravity_accel
	velocity.y += effective_gravity * delta

	# die if fell out of level
	if not _dying and global_position.y > 2000:
		kill()

	
	var horizontal: float = Input.get_action_strength("g_right") - Input.get_action_strength("g_left")
	if not _dying: # horizontal movement
		
		var effective_accel: float = walking_accel
		if Input.is_action_pressed("g_sprint"):
			effective_accel = sprinting_accel
		velocity.x += horizontal * effective_accel * delta
		velocity.x -= walking_drag * sign(velocity.x) * delta
		var effective_max_velocity: float = max_horizontal_velocity
		if abs(velocity.x) > max_horizontal_velocity + 50.0 or is_on_floor() and Input.is_action_pressed("g_sprint"):
			effective_max_velocity = sprinting_max_horizontal_velocity
		velocity.x = min(abs(velocity.x), effective_max_velocity) * sign(velocity.x)

	# sprite response
	if is_on_floor() and abs(horizontal) > 0.0:
		_sprite.flip_h = horizontal < 0.0
	if not _dying: # manage what animation plays and animation speed
		if Input.is_action_pressed("g_sprint"):
			_anim.playback_speed = _default_anim_speed + 1.0
		else:
			_anim.playback_speed = _default_anim_speed
		var to_play: String = "idle"
		if not is_on_floor(): 
			to_play = "jumping"
		elif abs(horizontal) > 0.0:
			if sign(horizontal) == sign(velocity.x):
				to_play = "forward"
			else:
				to_play = "reversing"
		_anim.play(to_play)

	# integrate
	var new_velocity: Vector2 = move_and_slide(velocity, Vector2(0, -1))

	# kill stuff if I jumped on it, hit blocks
	for c in get_slide_count():
		var collision: KinematicCollision2D = get_slide_collision(c)
		if collision.collider.is_in_group("jump_killable"):
			var center: Vector2 = collision.collider.get_collision_center()
			if (global_position - center).normalized().y < -jump_kill_tolerance:
				new_velocity.y = -jump_kill_velocity
				collision.collider.kill()
			else:
				kill()
		elif collision.collider.is_in_group("blocks"):
			if global_position.y > collision.collider.global_position.y and velocity.y < -0.1:
				collision.collider.hit()
	
	if not _dying:
		velocity = new_velocity
	
#	update() debug draw
#
#var col_pos := Vector2()
#func _draw():
#	draw_circle(to_local(col_pos), 5.0, Color(1, 0, 0))


func _on_DeathSoundPlayer_finished():
	emit_signal("dead")
