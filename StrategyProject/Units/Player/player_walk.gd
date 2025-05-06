class_name Player_Walk extends State

var IdleTimerActive: bool

func enter():
	pass

# Called when this state is deactivated
func exit():
	pass

# Called every physics frame while this state is active
func Update(_delta: float) -> State:
	var input_direction: Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
	if input_direction == Vector2.ZERO:
		return state_machine.states["Player_Idle"]
	
	character.movement_component.accelerate_in_direction(input_direction, _delta)
	character.movement_component.move()
	return
	
