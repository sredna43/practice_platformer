extends KinematicBody2D

export var speed: = Vector2(5.0, 700.0)
export var gravity: = 2000
export var floor_acceleration: = 50
export var jump_acceleration: = 10
export var friction: = 0.2
var motion: = Vector2()
var velocity: = Vector2.ZERO
const FLOOR_NORMAL = Vector2.UP
var direction: = Vector2()

onready var left_wall_raycasts: = $LeftWall
onready var right_wall_raycasts: = $RightWall

func _ready() -> void:
	$AnimationPlayer.play("idle", -1, 1.0, false)
	

func _physics_process(delta: float) -> void:
	var wall_jump: = false
	direction.y = 1
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var is_jump_interrupted: = Input.is_action_just_released("jump") and velocity.y < 0.0
	if Input.is_action_just_pressed("jump") and is_on_floor():
		direction.y = -1.0
	if Input.is_action_just_pressed("jump") and get_wall_slide() != 0.0 and not is_on_floor():
		direction.y = -1.0
		direction.x = get_wall_slide()
		wall_jump = true
	if direction.y == -1.0:
		if wall_jump:
			velocity.y = speed.y * direction.y
			velocity.x = speed.x * direction.x
		else:
			velocity.y = speed.y * direction.y
	# X direction caps
	if is_on_floor():
		if direction.x > 0.0:
			velocity.x = min(velocity.x + floor_acceleration, speed.x)
		elif direction.x < 0.0:
			velocity.x = max(velocity.x - floor_acceleration, -speed.x)
	else:
		if direction.x > 0.0:
			velocity.x = min(velocity.x + jump_acceleration, speed.x)
		elif direction.x < 0.0:
			velocity.x = max(velocity.x - jump_acceleration, -speed.x)
			
	if is_on_floor() and direction.x == 0.0:
		velocity.x *= friction
		
	# Y direction slowdown
	if is_jump_interrupted:
		velocity.y *= 0.3
	velocity.y += gravity * delta
	if velocity.y > 0.0 and get_wall_slide() != 0.0:
		velocity.y *= 0.8
	play_animation(direction, velocity)
	velocity = move_and_slide(velocity, FLOOR_NORMAL)	
	
	
func play_animation(direction: Vector2, velocity: Vector2) -> void:
	if direction.x < 0:
		$Sprite.flip_h = true
	if direction.x > 0:
		$Sprite.flip_h = false
	if is_on_floor():
		if direction.x == 0.0:
			$AnimationPlayer.play("idle")
		else:
			$AnimationPlayer.play("run", -1, 1.25)
	else:
		if velocity.y < 0.0 and get_wall_slide() == 0.0:
			$AnimationPlayer.play("jump")
		elif velocity.y > 0.0 and get_wall_slide() != 0.0:
			$AnimationPlayer.play("slide")
		else:
			$AnimationPlayer.play("fall")
	
	
func get_wall_slide() -> float:
	for raycast in left_wall_raycasts.get_children():
		if raycast.is_colliding():
			return 1.0
	for raycast in right_wall_raycasts.get_children():
		if raycast.is_colliding():
			return -1.0
	return 0.0