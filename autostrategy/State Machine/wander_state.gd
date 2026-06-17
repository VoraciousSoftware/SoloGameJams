class_name Wander_State extends State

var target_location: Vector2i
var current_path: Array[Vector2i] = []
var path_index: int = 0

func enter():
	var start_location = character.WorldRef.global_to_map(character.global_position)
	target_location = character.WorldRef.get_random_walkable_tile()
	current_path = character.WorldRef.AStarGrid.get_id_path(start_location, target_location)
	path_index = 0

# Called when this state is deactivated
func exit():
	pass

# Called every physics frame while this state is active
func Update(_delta: float) -> State:
	if current_path.is_empty() or path_index >= current_path.size():
		return state_machine.states["Idle_State"]
	
	var target_point = character.WorldRef.map_to_global(current_path[path_index])
	
	if character.global_position.distance_to(target_point) <= 5:
		path_index += 1
		return
	
	#character.rotation = pos.angle_to_point(target_location)
	character.movement_component.accelerate_in_direction(character.global_position.direction_to(target_point), _delta)
	character.movement_component.move()
	#character.movement_component.animate_sprite(_delta)
	return
