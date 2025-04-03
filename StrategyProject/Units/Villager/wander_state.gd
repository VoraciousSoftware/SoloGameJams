class_name Wander_State extends State

var target_location: Vector2
	

func enter():
	target_location = character.global_position + Vector2(rng.randf_range(-100, 100), rng.randf_range(-100, 100))

# Called when this state is deactivated
func exit():
	pass

func Input(event: InputEvent) -> State:
	return

# Called every physics frame while this state is active
func Update(_delta: float) -> State:
	if character.current_target:
		return state_machine.states["Charge_State"]
	
	var pos: Vector2 = character.global_position
	if pos.distance_to(target_location) < 10.0:
		return state_machine.states["Idle_State"]
	
	character.movement_component.accelerate_in_direction(pos.direction_to(target_location), _delta)
	character.movement_component.move()
	return
