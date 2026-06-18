class_name Cursor_Area extends Area2D

signal full

@onready var prog_bar: TextureProgressBar = %ProgBar
@onready var circle: CollisionShape2D = %CollisionShape2D

@export var max_val: float = 10.0
var current_val: float
var hovered_cows: Array[Node2D]

var original_bar_scale

func _ready() -> void:
	current_val = 0
	prog_bar.visible = true
	prog_bar.max_value = max_val
	prog_bar.value = current_val
	scale *= GameManager.Cursor_Radius_Mult
	original_bar_scale = prog_bar.scale
	
func _process(delta: float) -> void:
	position = get_global_mouse_position()
	increase(delta)
	if current_val >= max_val:
		decrease(max_val)
		for cow in hovered_cows:
			cow.tapped(GameManager.Click_Power)

# Any node can call this function to deal damage to this component
func decrease(amount: float) -> void:
	current_val = max(0, current_val - amount)
	prog_bar.value = current_val

func increase(amount: float) -> void:
	current_val = min(max_val, current_val + amount)
	
	# Smoothly animate the bar
	var tween = create_tween()
	tween.tween_property(prog_bar, "value", current_val, 0.05).set_trans(Tween.TRANS_CUBIC)
	
	prog_bar.value = current_val
	if prog_bar.value >= max_val:
		full.emit()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("cows"):
		hovered_cows.append(body)
	

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("cows"):
		if hovered_cows.has(body):
			hovered_cows.erase(body)

func _on_full() -> void:
	var larger = original_bar_scale * 1.2
	var tween = create_tween()
	tween.tween_property(prog_bar, "scale", larger, 0.2).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	tween = create_tween()
	tween.tween_property(prog_bar, "scale", original_bar_scale, 0.2).set_trans(Tween.TRANS_CUBIC)
