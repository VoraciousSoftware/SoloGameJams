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
@export var friction: float = 1000.0 # How quickly to stop

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

## Accelerates the owner towards the target direction.
## Call this from the owner's _physics_process when movement input is active.
## 'direction' should ideally be normalized, but we normalize it here for safety.
func accelerate_in_direction(direction: Vector2, delta: float):
	if not _owner_body: return # Safety check

	if direction == Vector2.ZERO:
		# If direction is zero, applying friction is usually desired.
		# The owner should call apply_friction instead in this case.
		# However, calling move_toward with a zero target also works like friction
		# if acceleration > 0, so we could technically handle it here,
		# but separating intent (accelerate vs decelerate) is cleaner.
		apply_friction(delta) # Delegate to friction logic if direction is zero
		return

	# Calculate target velocity and move towards it
	var target_velocity = direction.normalized() * max_speed
	_owner_body.velocity = _owner_body.velocity.move_toward(target_velocity, acceleration * delta)
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
