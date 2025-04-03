class_name Idle_State extends State

var IdleTimerActive: bool

func enter():
	IdleTimerActive = true
	%Idle_Timer.start(5.0)
	# Override in specific states

# Called when this state is deactivated
func exit():
	IdleTimerActive = false
	%Idle_Timer.stop()

func Input(event: InputEvent) -> State:
	return

# Called every physics frame while this state is active
func Update(_delta: float) -> State:
	if character.current_target:
		return state_machine.states["Charge_State"]
	
	if !IdleTimerActive:
		return state_machine.states["Wander_State"]
	return


func _on_idle_timer_timeout() -> void:
	IdleTimerActive = false
