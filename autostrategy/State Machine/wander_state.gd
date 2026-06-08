class_name Wander_State extends State

var target_location: Vector2i
var current_path: Array[Vector2] = []
var path_index: int = 0

func enter():
	print("enter wander")
	var range: int = character.WorldMapRef.get_grid_length()
	target_location = Vector2i(rng.randi_range(0, range), rng.randi_range(0, range))
	character.WorldMapRef.AStarGrid.get_id_path(character.WorldMapRef.GroundMapLayer.local_to_map(character.global_position), target_location)
	path_index = 0
# Called when this state is deactivated
func exit():
	print("exit wander")
	pass

# Called every physics frame while this state is active
func Update(_delta: float) -> State:
	if current_path.is_empty() or path_index >= current_path.size():
		return state_machine.states["Idle_State"]
	
	var target_point = current_path[path_index]
	character.movement_component.accelerate_in_direction(target_point, _delta)
	#character.rotation = pos.angle_to_point(target_location)
	character.movement_component.move()
	return
