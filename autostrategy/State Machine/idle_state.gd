class_name Idle_State extends State

var IdleTimerActive: bool = false
@export var timer_max: float = 5.0

func enter():
	IdleTimerActive = true
	%Idle_Timer.start(rng.randf_range(0.0, timer_max))
	# Override in specific states

# Called when this state is deactivated
func exit():
	IdleTimerActive = false
	%Idle_Timer.stop()

# Called every physics frame while this state is active
func Update(_delta: float) -> State:
	character.movement_component.apply_friction(_delta)
	character.movement_component.move()
	if !IdleTimerActive:
		return state_machine.states["Wander_State"]
	return

func _on_idle_timer_timeout() -> void:
	IdleTimerActive = false
