class_name BrownCow extends CharacterBody2D

@export var WorldRef: WorldMap
@onready var movement_component = %Movement_Component
@onready var sprite = $Sprite2D
@onready var custom_bar = %CustomBar
@onready var heart_part = %Heart_Particles
@onready var gloves: Array = [%Glove, %Glove2, %Glove3, %Glove4, %Glove5]

@onready var current_love: int = 0
@export var max_love: int = 5

@export var bounce_speed: float = 15
@export var bounce_amplitude: float = 0.1
var bounce_time: float = 0.0
var glove_index: int = 0

var reward: int = 1

func _ready() -> void:
	add_to_group("cows", true)

func _process(delta: float) -> void:
	animate_sprite(delta)

func tapped(val: int) -> void:
	play_pat_anim()
	custom_bar.prog_bar.visible = true
	current_love += val
	custom_bar.increase(val)
	
	if current_love >= max_love:
		if current_love / max_love >= 2:
			give_reward(current_love / max_love)
		else:
			give_reward(1)
		current_love = 0
		play_heart_anim()
		await get_tree().create_timer(0.5).timeout
		custom_bar.decrease(custom_bar.max_val)
		if current_love == 0:
			custom_bar.prog_bar.visible = false
		

func give_reward(mult: int) -> void:
	GameManager.Currency += reward * mult
	print("Reward Gained!", GameManager.Currency)

func play_pat_anim() -> void:
	gloves[glove_index].pat()
	glove_index += 1
	if glove_index >= gloves.size():
		glove_index = 0

func play_heart_anim() -> void:
	heart_part.amount = reward
	heart_part.emitting = true

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("Left Click"):
		tapped(GameManager.Click_Power)
		
func animate_sprite(delta: float) -> void:
	if sprite:
		var bounce_factor: float
		if velocity.length() > 15:
			bounce_time += delta * bounce_speed
			# Apply squash and stretch (X and Y invert each other)
		else:
			bounce_time += delta * bounce_speed * 0.6
			#bounce_time = 0.0
			#sprite.scale = sprite.scale.move_toward(Vector2(1, 1), delta * 5.0)
		bounce_factor = sin(bounce_time) * bounce_amplitude
		sprite.scale.x = 1.0 + bounce_factor
		sprite.scale.y = 1.0 - bounce_factor
