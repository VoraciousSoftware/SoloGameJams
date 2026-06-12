class_name WorldMap extends Node2D

@export var GridLength: int
@onready var GroundMapLayer: TileMapLayer = %GroundLayer
@onready var StrucMapLayer: TileMapLayer = %StructureLayer
@onready var HoverMapLayer: TileMapLayer = %SelectLayer
@onready var camera: Camera2D = %Camera2D
var AStarGrid: AStarGrid2D = AStarGrid2D.new()
var Rng = RandomNumberGenerator.new()
var Dic: Dictionary = {}
var HoveredTile: Vector2i = Vector2i.ZERO

func _ready() -> void:
	#read_drawn_map()
	generate_square_map(GridLength)
	init_nav_grid()
	
func read_drawn_map() -> void:
	Dic.clear()
	var used_cells: Array[Vector2i] = GroundMapLayer.get_used_cells()
	for cell_coords in used_cells:
		var cell_data: TileData = GroundMapLayer.get_cell_tile_data(cell_coords)
		if cell_data: 
			var is_walkable = cell_data.get_custom_data("walkable")
			var iron = 0.0
			var occupied_item = "nothing" 
			if !is_walkable:
				var atlas_tile = GroundMapLayer.get_cell_atlas_coords(cell_coords)
				if atlas_tile == Vector2i(2,0):
					occupied_item = "rock"
				if atlas_tile == Vector2i(2,1):
					occupied_item = "iron node"
					iron = 100.0
			
			Dic[str(cell_coords)] = {
				"walkable": is_walkable,
				"occupied_by": occupied_item,
				"iron_left": iron
			}
		
func generate_random_map() -> void:
	#Old Function
	for x in GridLength:
		for y in GridLength:
			var rand_int = Rng.randi_range(0, 100)
			if rand_int <= 95:
				Dic[str(Vector2i(x,y))] = {
					"Type" : "Plains",
					"Occupied_By" : null
				}
				rand_int = Rng.randi_range(0, 9)
				GroundMapLayer.set_cell(Vector2i(x,y), 1, Vector2i(1,rand_int))
			else: 
				Dic[str(Vector2i(x,y))] = {
					"Type" : "Plains",
					"Occupied_By" : "Boulder"
				}
				rand_int = Rng.randi_range(0, 1)
				GroundMapLayer.set_cell(Vector2i(x,y), 1, Vector2i(2,rand_int))
				
func generate_square_map(length: int) -> void:
	for x in length:
		for y in length:
			GroundMapLayer.set_cell(Vector2i(x,y), 0, Vector2i(1,2))
			var walkable: bool = true
			var object: String = "Nothing"
			if y == length - 1: #Bottom Edge
				GroundMapLayer.set_cell(Vector2i(x,y), 0, Vector2i(1,3))
				StrucMapLayer.set_cell(Vector2i(x,y), 0, Vector2i(9,3))
				walkable = false
				object = "Fence"
			if y == 0: #Top Edge
				GroundMapLayer.set_cell(Vector2i(x,y), 0, Vector2i(1,1))
				StrucMapLayer.set_cell(Vector2i(x,y), 0, Vector2i(9,3))
				walkable = false
				object = "Fence"
			if x == 0: #Left Edge
				GroundMapLayer.set_cell(Vector2i(x,y), 0, Vector2i(0,2))
				StrucMapLayer.set_cell(Vector2i(x,y), 0, Vector2i(8,4))
				walkable = false
				object = "Fence"
				if y == 0: #Top Left Corner
					GroundMapLayer.set_cell(Vector2i(x,y), 0, Vector2i(0,1))
					StrucMapLayer.set_cell(Vector2i(x,y), 0, Vector2i(8,3))
				if y == length - 1: #Bottom Left Corner
					GroundMapLayer.set_cell(Vector2i(x,y), 0, Vector2i(0,3))
					StrucMapLayer.set_cell(Vector2i(x,y), 0, Vector2i(8,5))
			if x == length - 1: #Right Edge
				GroundMapLayer.set_cell(Vector2i(x,y), 0, Vector2i(2,2))
				StrucMapLayer.set_cell(Vector2i(x,y), 0, Vector2i(10,4))
				walkable = false
				object = "Fence"
				if y == 0: #Top Right Corner
					GroundMapLayer.set_cell(Vector2i(x,y), 0, Vector2i(2,1))
					StrucMapLayer.set_cell(Vector2i(x,y), 0, Vector2i(10,3))
				if y == length - 1: #Bottom Right Corner
					GroundMapLayer.set_cell(Vector2i(x,y), 0, Vector2i(2,3))
					StrucMapLayer.set_cell(Vector2i(x,y), 0, Vector2i(10,5))
				
			Dic[str(Vector2i(x,y))] = {
					"walkable" : walkable,
					"occupied_by" : object
				}
			
	set_camera_pos()			

func _process(delta: float) -> void:
	return


func hover_tile() -> void:
	var tile : Vector2i = GroundMapLayer.local_to_map(get_global_mouse_position())
	if tile != HoveredTile:
		HoverMapLayer.erase_cell(HoveredTile)
		HoveredTile = tile
	if Dic.has(str(tile)):
		HoverMapLayer.set_cell(tile, 1, Vector2i(0,0))

func init_nav_grid() -> void:
	AStarGrid.region = Rect2i(0,0,get_grid_length(),get_grid_length())
	AStarGrid.cell_size = GroundMapLayer.tile_set.tile_size
	AStarGrid.update()
	AStarGrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	
	for x in get_grid_length():
		for y in get_grid_length():
			if Dic[str(Vector2i(x,y))]["walkable"] == false:
				AStarGrid.set_point_solid(Vector2i(x,y), true)


func map_to_global(coord: Vector2i) -> Vector2:
	return to_global(GroundMapLayer.map_to_local(coord))

func global_to_map(coord: Vector2) -> Vector2i:
	return to_local(GroundMapLayer.local_to_map(coord))

func get_grid_length() -> float:
	return sqrt(Dic.size())
	
func get_random_walkable_tile() -> Vector2i:
	var used_cells: Array[Vector2i] = GroundMapLayer.get_used_cells()
	var valid_cells: Array[Vector2i]
	for cell_coords in used_cells:
		var cell_data: TileData = GroundMapLayer.get_cell_tile_data(cell_coords)
		if cell_data: 
			if cell_data.get_custom_data("walkable") == true: #uses custom data layers, not dic value
				valid_cells.append(cell_coords)
	return valid_cells.pick_random()
	
func set_camera_pos() -> void:
	camera.global_position = map_to_global(Vector2i(get_grid_length()/2, get_grid_length()/2))
	
