extends Node2D

@onready var Cow_Population: int = 1
@onready var Currency: int = 0
@onready var Click_Power: int = 1
@onready var Cursor_Radius_Mult: float = 1


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
