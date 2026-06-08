class_name Idle_State extends State

var IdleTimerActive: bool = false

func enter():
	print("Idle")
	IdleTimerActive = true
	%Idle_Timer.start(rng.randf_range(0.0, 1.0))
	# Override in specific states

# Called when this state is deactivated
func exit():
	print("leaving Idle")
	IdleTimerActive = false
	%Idle_Timer.stop()

# Called every physics frame while this state is active
func Update(_delta: float) -> State:
	if !IdleTimerActive:
		return state_machine.states["Wander_State"]
	return

func _on_idle_timer_timeout() -> void:
	IdleTimerActive = false
