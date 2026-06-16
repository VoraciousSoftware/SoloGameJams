class_name BrownCow extends CharacterBody2D

@export var WorldRef: WorldMap
@onready var movement_component = %Movement_Component
@onready var sprite = $Sprite2D

@onready var current_love: int = 0
@export var max_love: int = 5

var reward: int = 1

func tapped(val: int) -> void:
	current_love += val
	
	if current_love >= max_love:
		if current_love / max_love >= 2:
			give_reward(current_love / max_love)
		else:
			give_reward(1)
		current_love = 0
	
	print("Click Cow")

func give_reward(mult: int) -> void:
	GameManager.Currency += reward * mult
	print("Reward Gained!", GameManager.Currency)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("Left Click"):
		tapped(GameManager.Click_Power)
