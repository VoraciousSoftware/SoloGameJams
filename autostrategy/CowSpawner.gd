extends Node

@export var SpawnAmount: int = 0
@export var WorldRef: WorldMap = null

const COW_SCENE = preload("res://Brown_Cow.tscn")

func _ready() -> void:
	SpawnCows(SpawnAmount)

func SpawnCows(num: int) -> void:
	for i in num:
		var cow_inst = COW_SCENE.instantiate()
		add_child(cow_inst)
		cow_inst.WorldRef = WorldRef
		cow_inst.global_position = WorldRef.map_to_global(WorldRef.get_random_walkable_tile())
	
