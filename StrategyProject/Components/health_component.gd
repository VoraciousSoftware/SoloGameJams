class_name HealthComponent extends Node


## Manages the health of an entity, allowing it to take damage and die.

## Emitted when the current health changes. Sends the new health and max health.
signal health_changed(current_health: float, max_health: float)
## Emitted when the health reaches zero or below.
signal died

@export var max_health: float = 100.0 : set = set_max_health

var current_health: float

# --- Lifecycle Methods ---

func _ready():
	# Initialize health when the component enters the scene tree
	# Use the setter to ensure initial signal emission if needed elsewhere
	set_current_health(max_health)
	print(get_owner().name, " HealthComponent ready. Health: ", current_health, "/", max_health)


# --- Public Methods ---

## Applies damage to the entity.
func take_damage(amount: float):
	if amount <= 0: # Don't process non-positive damage
		return
	if is_dead(): # Already dead, do nothing
		return

	var previous_health = current_health
	current_health = max(current_health - amount, 0.0) # Clamp health >= 0

	print(get_owner().name, " took ", amount, " damage. Health: ", current_health, "/", max_health)

	# Emit signal only if health actually changed
	if current_health != previous_health:
		health_changed.emit(current_health, max_health)

	# Check for death *after* applying damage and emitting health change
	if is_dead():
		print(get_owner().name, " died.")
		died.emit()

## Heals the entity.
func heal(amount: float):
	if amount <= 0: # Don't process non-positive healing
		return
	if is_dead(): # Can't heal the dead (usually)
		return

	var previous_health = current_health
	current_health = min(current_health + amount, max_health) # Clamp health <= max_health

	print(get_owner().name, " healed ", amount, " points. Health: ", current_health, "/", max_health)

	# Emit signal only if health actually changed
	if current_health != previous_health:
		health_changed.emit(current_health, max_health)


## Returns true if the current health is zero or less.
func is_dead() -> bool:
	return current_health <= 0


## Directly sets the current health value, clamping it and emitting signals.
func set_current_health(value: float):
	var previous_health = current_health
	current_health = clamp(value, 0.0, max_health)
	if current_health != previous_health:
		health_changed.emit(current_health, max_health)
	if is_dead() and previous_health > 0: # Check if this action caused death
		died.emit()


## Sets the maximum health, also adjusting current health if necessary.
func set_max_health(value: float):
	if value <= 0:
		push_warning("Max health must be positive.")
		value = 1.0 # Ensure max_health is always positive

	max_health = value
	# If current health exceeds new max, clamp it down
	if current_health > max_health:
		set_current_health(max_health) # Use setter to emit signal if needed
	elif not is_inside_tree():
		# If not in tree yet (e.g. set via inspector), just update max
		pass # _ready will set current_health later
	else:
		# Max health changed, but current health might still be valid
		# Emit health_changed so UI etc can update max value display
		health_changed.emit(current_health, max_health)

# --- Getters (Optional but can be convenient) ---

func get_health() -> float:
	return current_health

func get_max_health() -> float:
	return max_health

func get_health_ratio() -> float:
	if max_health > 0:
		return current_health / max_health
	else:
		return 0.0 # Avoid division by zero
