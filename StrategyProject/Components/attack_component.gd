class_name AttackComponent extends Node

@export var attack_damage: float = 10
@export var attack_cooldown: float = 2.0
@export var attack_range: float = 25.0
@export var knockback: float = 0.0


@onready var can_attack: bool = true
@onready var timer: Timer = %Attack_Timer


func perform_attack(target: Node2D):
	if can_attack:
		if target:
			if target.has_method("hit"):
				target.hit(attack_damage)
				can_attack = false
				timer.start(attack_cooldown)

func _on_attack_timer_timeout() -> void:
	can_attack = true # Replace with function body.
