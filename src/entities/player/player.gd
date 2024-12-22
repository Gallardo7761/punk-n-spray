extends CharacterBody2D

# Variable definitions
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var SCREEN_SIZE
var original_collision_mask

# Initialize things
func _ready() -> void:
	SCREEN_SIZE = get_viewport_rect().size
	original_collision_mask = collision_mask
	
# Game loop
func _process(delta: float) -> void:

	# Animations	
	if velocity.x != 0:
		$AnimatedSprite2D.play()
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x > 0
	else:
		$AnimatedSprite2D.stop()		

# Handling physics
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if is_on_platform() and Input.is_action_just_pressed("crouch"):
		collision_mask &= 1
	
	if not Input.is_action_pressed("crouch") and collision_mask != original_collision_mask:
		collision_mask = original_collision_mask
	
	move_and_slide()
	
func is_on_platform():
	return is_on_floor() and collision_mask == 3
