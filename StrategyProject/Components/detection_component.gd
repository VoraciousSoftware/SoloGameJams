# res://components/DetectionComponent.gd
class_name DetectionComponent extends Area2D

## Detects bodies within its area based on a specified group.
## Requires a CollisionShape2D child node.

## Emitted when a body belonging to the target group enters the area.
signal detected(body: Node2D)
## Emitted when a body that was previously detected leaves the area.
signal lost_detection(body: Node2D)

## The collision group name to look for (e.g., "player", "enemies", "interactables").
@export var target_group: String = "Targetable"

## Optional: Convenience export to set the radius if the child is a CircleShape2D.
@export var detection_radius: float = 150.0 : set = set_detection_radius

# --- Internal State ---
## Stores the bodies currently inside the area that match the target group.
var detected_bodies: Array[Node2D] = []

# --- Node References ---
@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")

# --- Lifecycle Methods ---

func _ready():
	# Validate that a CollisionShape2D child exists
	if not collision_shape:
		push_error("DetectionComponent '%s' requires a CollisionShape2D child node named 'CollisionShape2D'!" % name)
		# Optionally disable monitoring if shape is missing
		monitoring = false
		monitorable = false # Usually also disable monitorable if it can't detect
		return

	# Apply the radius set in the inspector (or default)
	# Call the setter to ensure the shape gets updated if it's a circle
	set_detection_radius(detection_radius)

	# --- Connect the Area2D's built-in signals ---
	# These signals fire for *any* physics body entering/exiting.
	# We will filter them in our handler functions.
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Check for any bodies already overlapping when this component becomes ready
	# This handles cases where the component is added while already overlapping.
	_check_initial_overlaps()

	print(get_owner().name if get_owner() else name, " DetectionComponent ready. Monitoring group '", target_group, "'.")


# --- Signal Handlers for Area2D ---

func _on_body_entered(body: Node):
	if body == get_parent():
		return
	# Check if the entered body is in the target group AND not already tracked
	if not target_group.is_empty() and body.is_in_group(target_group) and not detected_bodies.has(body):
		detected_bodies.append(body)
		detected.emit(body) # Emit our custom signal
		# print("Detected: ", body.name) # Debug


func _on_body_exited(body: Node):
	# Check if the exited body *was* being tracked
	if detected_bodies.has(body):
		detected_bodies.erase(body) # Remove from our list
		lost_detection.emit(body) # Emit our custom signal
		# print("Lost detection: ", body.name) # Debug


# --- Public Methods / Getters ---

## Returns a list of all currently detected bodies matching the target group.
## Returns a copy, so modifying the returned array doesn't affect the internal state.
func get_detected_bodies() -> Array[Node2D]:
	return detected_bodies.duplicate() # Return a copy


## Checks if any valid target is currently detected.
func has_detection() -> bool:
	return not detected_bodies.is_empty()


## Finds the detected body closest to this component's position.
## Returns null if no bodies are currently detected.
func get_closest_detection() -> Node2D:
	var closest_body: Node2D = null
	var min_distance_sq = INF # Use squared distance for efficiency

	if not has_detection():
		return null

	for body in detected_bodies:
		# Ensure the body hasn't been freed since detection
		if not is_instance_valid(body):
			# Note: This case is less common with physics callbacks but good practice.
			# The body_exited signal should handle removal if freed properly.
			printerr("Detected body became invalid before distance check!")
			# Optionally force remove it here, though _on_body_exited should handle it.
			# detected_bodies.erase(body) # Be careful if iterating while modifying
			continue

		var distance_sq = global_position.distance_squared_to(body.global_position)
		if distance_sq < min_distance_sq:
			min_distance_sq = distance_sq
			closest_body = body

	return closest_body


# --- Setters ---

## Updates the detection radius, but only if the child shape is a CircleShape2D.
func set_detection_radius(value: float):
	detection_radius = value
	# Check if the node is ready and the shape is valid
	if not is_inside_tree() or not is_instance_valid(collision_shape):
		return # collision_shape might not be ready yet, _ready will handle it

	# Attempt to cast the shape to a CircleShape2D
	var circle_shape = collision_shape.shape as CircleShape2D
	if circle_shape:
		circle_shape.radius = detection_radius
	# else: # Optional warning if it's not a circle
		# if detection_radius != 200.0: # Only warn if user changed it from default
			# push_warning("DetectionComponent '%s': Tried to set radius, but child CollisionShape2D is not a CircleShape2D." % name)

# --- Private Helpers ---

## Checks bodies already overlapping when the node enters the tree or becomes ready.
func _check_initial_overlaps():
	# Get all currently overlapping bodies
	var overlapping_bodies = get_overlapping_bodies()
	for body in overlapping_bodies:
		# Manually run the 'entered' logic for existing overlaps
		# This ensures consistency if enabled mid-overlap.
		_on_body_entered(body)
