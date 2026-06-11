class_name WorldMap extends Node2D

@export var GridSize: int
@onready var GroundMapLayer: TileMapLayer = %GroundLayer
@onready var HoverMapLayer: TileMapLayer = %SelectLayer
var AStarGrid: AStarGrid2D = AStarGrid2D.new()
var Rng = RandomNumberGenerator.new()
var Dic: Dictionary = {}
var HoveredTile: Vector2i = Vector2i.ZERO

func _ready() -> void:
	read_drawn_map()
	init_nav_grid()
	#print(Dic)
	
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
	for x in GridSize:
		for y in GridSize:
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

func _process(delta: float) -> void:
	var tile : Vector2i = GroundMapLayer.local_to_map(get_global_mouse_position())
	#print(str(tile))
	if tile != HoveredTile:
		HoverMapLayer.erase_cell(HoveredTile)
		HoveredTile = tile
		
	if Dic.has(str(tile)):
		HoverMapLayer.set_cell(tile, 1, Vector2i(0,0))
		#print(Dic[str(tile)])
		#print(AStarGrid.is_point_solid(tile))
		
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
	for cell_coords in used_cells:
		var cell_data: TileData = GroundMapLayer.get_cell_tile_data(cell_coords)
		if cell_data: 
			if !cell_data.get_custom_data("walkable"):
				used_cells.erase(cell_coords)
				
	return used_cells.pick_random()
	
