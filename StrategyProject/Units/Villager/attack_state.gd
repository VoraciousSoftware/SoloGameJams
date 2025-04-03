class_name Attack_State extends State

var target: Node2D
	

func enter():
	pass

# Called when this state is deactivated
func exit():
	pass

func Input(event: InputEvent) -> State:
	return

# Called every physics frame while this state is active
func Update(_delta: float) -> State:
	if !character.current_target:
		return state_machine.states["Idle_State"]
	
	var pos: Vector2 = character.global_position
	var target_location = character.current_target.global_position
	if pos.distance_to(target_location) > character.attack_component.attack_range:
		return state_machine.states["Charge_State"]
	
	character.attack_component.perform_attack(character.current_target)
	
	return
