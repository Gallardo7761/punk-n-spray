extends CharacterBody2D

# Variable definitions
const SPEED = 50.0
const JUMP_VELOCITY = -400.0

# Action variables
var RUN_ACTION = Input.is_action_pressed("run")
var JUMP_ACTION = Input.is_action_pressed("jump")
var WALK_ACTION = Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")
var WALK_RIGHT = Input.is_action_pressed("move_right")
var WALK_LEFT = Input.is_action_pressed("move_left")
var CROUCH_ACTION = Input.is_action_pressed("crouch")

# Misc variables
var screen_size
var original_collision_mask

# Initialize things
func _ready() -> void:
	screen_size = get_viewport_rect().size
	original_collision_mask = collision_mask
	
# Game loop
func _process(_delta: float) -> void:
	RUN_ACTION = Input.is_action_pressed("run")
	JUMP_ACTION = Input.is_action_pressed("jump")
	WALK_ACTION = Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")
	WALK_RIGHT = Input.is_action_pressed("move_right")
	WALK_LEFT = Input.is_action_pressed("move_left")
	CROUCH_ACTION = Input.is_action_pressed("crouch")

	# Animations
	$AnimatedSprite2D.play()
	$AnimatedSprite2D.flip_v = false
	$AnimatedSprite2D.flip_h = velocity.x < 0
	
	# Moving animations
	if velocity.x != 0:
		if RUN_ACTION:
			if JUMP_ACTION and not is_on_floor():
				$AnimatedSprite2D.animation = "jump"
			else:
				$AnimatedSprite2D.animation = "run"
		elif WALK_ACTION:
			if CROUCH_ACTION:
				$AnimatedSprite2D.animation = "crouch_walk"
			elif JUMP_ACTION and not is_on_floor():
				$AnimatedSprite2D.animation = "jump"
			else:
				$AnimatedSprite2D.animation = "walk"
	# Idle animations
	else: 
		if CROUCH_ACTION:
			$AnimatedSprite2D.animation = "crouch_idle"
		elif JUMP_ACTION and not is_on_floor():
			$AnimatedSprite2D.animation = "jump"
		else:
			$AnimatedSprite2D.animation = "idle"

# Game loop for handling physics
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if Input.is_action_pressed("crouch"):
			velocity.y = 0.65 * JUMP_VELOCITY
		elif Input.is_action_pressed("run"):
			velocity.y = 1.15 * JUMP_VELOCITY
		else:
			velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		if Input.is_action_pressed("run"):
			velocity.x = direction * 3 * SPEED
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Drop off platforms
	if is_on_platform() and Input.is_action_just_pressed("crouch"):
		collision_mask &= 1
	
	if not Input.is_action_pressed("crouch") and collision_mask != original_collision_mask:
		collision_mask = original_collision_mask
	
	move_and_slide()
	
# This auxiliary function calculates if the player 
# is over a platform by simply evaluating if it's 
# on a floor and its collision mask is 0x3 (3) which
# is the platforms' collision mask
func is_on_platform():
	return is_on_floor() and collision_mask == 3
