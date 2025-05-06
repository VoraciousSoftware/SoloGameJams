class_name Player extends CharacterBody2D

@onready var state_machine: StateMachine = %State_Machine
@onready var health_component: HealthComponent = %Health_Component
@onready var movement_component: MovementComponent = %Movement_Component
@onready var attack_component: AttackComponent = %Attack_Component

var current_target: Node2D = null
var home_location: Vector2

func _ready() -> void:
	
	if health_component:
		health_component.died.connect(_on_death)

func hit(damage_amount: float):
	if health_component:
		health_component.take_damage(damage_amount)
		print(name + " took " + str(damage_amount) + " damage!")
	else:
		print("Attempted to hit villager, but it has no HealthComponent!")

func _on_death():
	print(name + " is handling its death!")
	queue_free()
