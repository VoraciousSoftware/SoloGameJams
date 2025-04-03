class_name StateMachine extends Node

var current_state: State 
var states: Dictionary = {}

func _ready():
	var character = get_owner() # Assumes StateMachine is direct child of Enemy

	# Find all child nodes that are States and initialize them
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.initialize(character, self) # Pass references down
		else:
			# If a node like Timer is a child, ignore it for state logic
			print("StateMachine child is not a State: ", child.name)

	# Set and enter the initial state
	if states.size() > 0:
		# Fallback if initial_state wasn't set in inspector
		push_warning("StateMachine initial_state not set in Inspector! Defaulting to first found state.")
		change_state(states.values()[0])
	else:
		push_error("StateMachine has no State child nodes!")


func _physics_process(delta: float) -> void:
	if !current_state:
		return
	
	var new_state = current_state.Update(delta)
	if new_state:
		change_state(new_state)	
		
func _input(event: InputEvent) -> void:
	if !current_state:
		return
	
	var new_state = current_state.Input(event)
	if new_state:
		change_state(new_state)

func change_state(new_state: State):
	if new_state == null or new_state == current_state:
		return
	# Call exit logic on the outgoing state
	if current_state:
		current_state.exit()
	# Set the new state and call its enter logic
	current_state = new_state
	current_state.enter()
	print("Enemy changed state to: ", current_state.name)


# Optional: Helper to get a state by name if needed
func get_state(state_name: StringName) -> State:
	return states.get(state_name)
