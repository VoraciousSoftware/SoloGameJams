class_name Villager extends CharacterBody2D

@onready var state_machine: StateMachine = %State_Machine
@onready var health_component: HealthComponent = %Health_Component
@onready var movement_component: MovementComponent = %Movement_Component
@onready var detection_component: DetectionComponent = %Detection_Component
@onready var attack_component: AttackComponent = %Attack_Component

var current_target: Node2D = null
var home_location: Vector2

func _ready() -> void:
	
	if health_component:
		health_component.died.connect(_on_death)
		
	detection_component.detected.connect(_on_target_detected)
	detection_component.lost_detection.connect(_on_target_lost)

func hit(damage_amount: float):
	if health_component:
		health_component.take_damage(damage_amount)
		print(name + " took " + str(damage_amount) + " damage!")
	else:
		print("Attempted to hit villager, but it has no HealthComponent!")

func _on_death():
	print(name + " is handling its death!")
	queue_free()

func _on_target_detected(body: Node2D):
	# Always switch to the closest if > 1 detected
	update_target()


func _on_target_lost(body: Node2D):
	print(name, " lost detection of ", body.name)
	# If the body that left is our *current* target, lose the target.
	if body == current_target:
		current_target = null
		print(name, " lost current target.")
		#Immediately check if other targets are still in range
		update_target()


# --- Optional Helper to Update Target (e.g., find closest) ---
func update_target():
	if detection_component:
		current_target = detection_component.get_closest_detection()
		if current_target:
			print(name, " updated target to closest: ", current_target.name)
