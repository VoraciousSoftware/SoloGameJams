# State.gd
class_name State extends Node

# References set by the StateMachine
var character: CharacterBody2D
var state_machine: StateMachine # Reference to the StateMachine node itself
@onready var rng := RandomNumberGenerator.new()
# Called once when the state machine is ready (by the StateMachine)
func initialize(_character: CharacterBody2D, _state_machine):
	self.character = _character
	self.state_machine = _state_machine

# Called when this state becomes active
func enter():
	pass # Override in specific states

# Called when this state is deactivated
func exit():
	pass # Override in specific states

func Input(event: InputEvent) -> State:
	return

# Called every physics frame while this state is active
func Update(_delta: float) -> State:
	return
