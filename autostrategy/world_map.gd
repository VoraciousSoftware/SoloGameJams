extends Node2D

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
	print(Dic)
	
func read_drawn_map() -> void:
	Dic.clear()
	var used_cells: Array[Vector2i] = GroundMapLayer.get_used_cells()
	for cell_coords in used_cells:
		var cell_data: TileData = GroundMapLayer.get_cell_tile_data(cell_coords)
		if cell_data: 
			var is_walkable = cell_data.get_custom_data("walkable")
			Dic[str(cell_coords)] = {
				"walkable": is_walkable,
				"occupied_by": null,
				"atlas_coords": GroundMapLayer.get_cell_atlas_coords(cell_coords)
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
	print(str(tile))
	
	if tile != HoveredTile:
		HoverMapLayer.erase_cell(HoveredTile)
		HoveredTile = tile
		
	if Dic.has(str(tile)):
		HoverMapLayer.set_cell(tile, 1, Vector2i(0,0))
		print(Dic[str(tile)])
		print(AStarGrid.is_point_solid(tile))
		
func init_nav_grid() -> void:
	AStarGrid.region = Rect2i(0,0,5,5)
	AStarGrid.cell_size = GroundMapLayer.tile_set.tile_size
	AStarGrid.update()
	
	#for x in 5:
		#for y in 5:
			#if Dic[str(Vector2i(x,y))]["occupied_by"] == "Boulder":
				#AStarGrid.set_point_solid(Vector2i(x,y), true)
				
	
	
