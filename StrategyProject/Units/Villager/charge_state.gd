class_name Charge_State extends State

var target_location: Vector2
	

func enter():
	target_location = character.current_target.global_position

# Called when this state is deactivated
func exit():
	pass

func Input(event: InputEvent) -> State:
	return

# Called every physics frame while this state is active
func Update(_delta: float) -> State:
	if character.current_target == null:
		return state_machine.states["Wander_State"]
	
	var pos: Vector2 = character.global_position
	target_location = character.current_target.global_position
	if pos.distance_to(target_location) < character.attack_component.attack_range:
		return state_machine.states["Attack_State"]
	
	character.movement_component.accelerate_in_direction(pos.direction_to(target_location), _delta)
	character.movement_component.move()
	return
