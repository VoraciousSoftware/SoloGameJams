class_name Investigate_State extends State

var target_location: Vector2
var investigating: bool

func enter():
	target_location = character.last_location
	investigating = true

# Called when this state is deactivated
func exit():
	pass

# Called every physics frame while this state is active
func Update(_delta: float) -> State:
	if character.current_target:
		return state_machine.states["Charge_State"]
	
	var pos: Vector2 = character.global_position
	if pos.distance_to(target_location) < 10.0:
		if investigating: 
			#Look around? 
			return state_machine.states["Idle_State"]
		else:
			return state_machine.states["Idle_State"]
	
	character.movement_component.accelerate_in_direction(pos.direction_to(target_location), _delta)
	#character.rotation = pos.angle_to_point(target_location)
	character.movement_component.move()
	return
