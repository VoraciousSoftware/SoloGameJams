# res://components/MovementComponent.gd
class_name MovementComponent extends Node

## Handles movement physics like acceleration, friction, and max speed
## for a CharacterBody2D owner.

## Emitted when the movement starts (velocity becomes non-zero from zero).
# signal movement_started
## Emitted when the movement stops (velocity becomes zero).
# signal movement_stopped
## Note: Signals can add complexity; let's omit them for this basic version.
## The owner can check its own velocity if needed.

# --- Configuration ---
@export var max_speed: float = 150.0
@export var acceleration: float = 800.0
@export var turn_speed: float = 10.0
@export var friction: float = 1000.0 # How quickly to stop
@export var bounce_speed: float = 10
@export var bounce_amplitude: float = 10

var bounce_time: float = 0.0

# --- State ---
# We will directly modify the velocity of the owner CharacterBody2D
# var current_velocity: Vector2 = Vector2.ZERO # Not needed if modifying owner directly

# --- Private ---
var _owner_body: CharacterBody2D

func _ready():
	# Get the owner node, assuming this component is a direct child.
	# Important: This component *must* be a child of a CharacterBody2D.
	_owner_body = get_owner() as CharacterBody2D
	if not _owner_body:
		push_error("MovementComponent must be a child of a CharacterBody2D node!")
		# Optionally disable processing if owner is invalid
		set_process(false)
		set_physics_process(false)
	else:
		print(_owner_body.name, " MovementComponent ready.")


# --- Public Movement Methods ---

func animate_sprite(delta: float) -> void:
	var sprite = _owner_body.find_child("Sprite2D")
	if sprite:
		if _owner_body.velocity.length() > 0:
			bounce_time += delta * bounce_speed
			var bounce_factor = sin(bounce_time) * bounce_amplitude
			# Apply squash and stretch (X and Y invert each other)
			sprite.scale.x = 1.0 + bounce_factor
			sprite.scale.y = 1.0 - bounce_factor
		else:
			bounce_time = 0.0
			sprite.scale = sprite.scale.move_toward(Vector2(1, 1), delta * 5.0)

## Accelerates the owner towards the target direction.
func accelerate_in_direction(direction: Vector2, delta: float):
	if not _owner_body: return # Safety check

	if direction == Vector2.ZERO:
		apply_friction(delta) # Delegate to friction logic if direction is zero
		return

	# Calculate target velocity and move towards it
	var target_velocity = direction.normalized() * max_speed
	_owner_body.velocity = _owner_body.velocity.move_toward(target_velocity, acceleration * delta)
	if _owner_body.velocity.x < 0:
		_owner_body.sprite.flip_h = false
	elif _owner_body.velocity.x > 0:
		_owner_body.sprite.flip_h = true
	#_owner_body.rotation = lerp_angle(_owner_body.rotation, direction.angle(), turn_speed * delta)
	# print("Accelerating: ", _owner_body.velocity) # Debug


## Applies friction to slow down the owner.
## Call this from the owner's _physics_process when there is no movement input.
func apply_friction(delta: float):
	if not _owner_body: return # Safety check

	_owner_body.velocity = _owner_body.velocity.move_toward(Vector2.ZERO, friction * delta)
	# print("Applying friction: ", _owner_body.velocity) # Debug


## Executes the actual movement based on the owner's current velocity.
## Call this *after* accelerate_in_direction or apply_friction in the owner's _physics_process.
func move():
	if not _owner_body: return # Safety check

	# The core Godot movement function for CharacterBody2D
	_owner_body.move_and_slide()
	


# --- Getters (Optional) ---

func get_current_velocity() -> Vector2:
	if _owner_body:
		return _owner_body.velocity
	return Vector2.ZERO

func is_moving() -> bool:
	if _owner_body:
		# Use a small threshold to account for floating point inaccuracies
		return not _owner_body.velocity.is_zero_approx()
	return false
