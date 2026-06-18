class_name CustomBar extends Node

signal val_changed(current_val: float)
signal died

@onready var prog_bar: TextureProgressBar = %ProgBar

@export var max_val: float = 10.0
var current_val: float

func _ready() -> void:
	current_val = 0
	prog_bar.visible = false
	prog_bar.max_value = max_val
	prog_bar.value = current_val
	
func _process(delta: float) -> void:
	prog_bar.position = get_parent().global_position + Vector2(-12, 17)

# Any node can call this function to deal damage to this component
func decrease(amount: float) -> void:
	current_val = max(0, current_val - amount)
	
	# Smoothly animate the bar
	var tween = create_tween()
	tween.tween_property(prog_bar, "value", current_val, 0.1).set_trans(Tween.TRANS_CUBIC)
	
	# Emit signals for modularity
	val_changed.emit(current_val)
	
	if current_val <= 0:
		died.emit()

func increase(amount: float) -> void:
	current_val = min(max_val, current_val + amount)
	
	# Smoothly animate the bar
	var tween = create_tween()
	tween.tween_property(prog_bar, "value", current_val, 0.1).set_trans(Tween.TRANS_CUBIC)
	
	prog_bar.value = current_val
	val_changed.emit(current_val)
