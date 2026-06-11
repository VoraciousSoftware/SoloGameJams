class_name Wander_State extends State

var target_location: Vector2i
var current_path: Array[Vector2i] = []
var path_index: int = 0

func enter():
	print("enter wander")
	var start_location = character.WorldMapRef.global_to_map(character.global_position)
	target_location = character.WorldMapRef.get_random_walkable_tile()
	print(start_location)
	print(target_location)
	current_path = character.WorldMapRef.AStarGrid.get_id_path(start_location, target_location)
	print(current_path)
	path_index = 0

# Called when this state is deactivated
func exit():
	print("exit wander")
	pass

# Called every physics frame while this state is active
func Update(_delta: float) -> State:
	if current_path.is_empty() or path_index >= current_path.size():
		return state_machine.states["Idle_State"]
	
	var target_point = character.WorldMapRef.map_to_global(current_path[path_index])
	
	if character.global_position.distance_to(target_point) <= 50:
		path_index += 1
		if path_index < current_path.size():
			print(current_path[path_index]) 
		return
	
	#character.rotation = pos.angle_to_point(target_location)
	character.movement_component.accelerate_in_direction(character.global_position.direction_to(target_point), _delta)
	character.movement_component.move()
	return
