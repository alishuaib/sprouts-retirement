extends Node2D

var tile_size = Vector2(16,16)
var tiles :Dictionary = {}

var default_crop = {
	"rid": 0,
	"name": "default",
	"coords": Vector2.ZERO,
	"rect": null,
	"timer": null,
	"stage": 0,
	"quantity": 0,
	"value": 0,
	"time": 60/60,
}
@onready var sprites2 :Sprite2D= $SPR_Crops

var sprites :Dictionary = {
	"tomato": {
		"stage1": preload("res://assets/food/ghostpixel/01_dish.png"),
		"stage2": preload("res://assets/food/ghostpixel/04_bowl.png"), 
		"quantity": 6, 
		"value": 1, 
		"time": 60},
}

# Growth stages for the sprite sheet
enum GROWTH_STAGES {
	EMPTY = 0,
	GROWING = 1,
	MATURED = 2,
}

func _ready():
	# Adds the marker2d into an array to represent the tiles
	var markers = get_node("MarkerList")
	for row in markers.get_children():
		for coord:Marker2D in row.get_children():
			tiles[coord.position] = {"rect": Rect2(adjust_rect_position(coord.position), tile_size), "timer": null, "produce_Key": null, "stage": GROWTH_STAGES.EMPTY, "sprite": null}

# because Rect2 position is top left and not middle of itself
func adjust_rect_position(coord :Vector2):
	return Vector2(coord.x-(tile_size.x/2), coord.y-(tile_size.y/2))
	
# get a tile's center coordinate
# there has to be a better way than looping with for right?
func get_tile(mouse_position: Vector2):
	for coord in tiles:
		if tiles[coord]["rect"].has_point(mouse_position):
			return coord
	

func _input(_event :InputEvent):
	if Input.is_action_just_released("Tile Select"):
		var mouse_position = get_local_mouse_position()
		var tile_coord = get_tile(mouse_position)
		if !tile_coord:
			return
		
		# If click is within a tile, creates a timer 
		if tiles[tile_coord]["stage"] == GROWTH_STAGES.EMPTY: 
			var newTimer: Timer = Timer.new()
			newTimer.wait_time = sprites["tomato"]["time"]/20
			newTimer.one_shot = true
			newTimer.autostart = true
			newTimer.timeout.connect(timer_done.bind(tile_coord))
			tiles[tile_coord]["timer"] = newTimer
			tiles[tile_coord]["produce_key"] = randi_range(0,1)
			process_tile(tile_coord)
			$TimerList.add_child(newTimer)
		elif tiles[tile_coord]["stage"] == GROWTH_STAGES.GROWING:
			print("in progress...")
		elif tiles[tile_coord]["stage"] == GROWTH_STAGES.MATURED:
			process_tile(tile_coord)
	
func timer_done(tile_coord: Vector2):
	if tiles[tile_coord]["timer"] != null:
		tiles[tile_coord]["timer"].queue_free()
		tiles[tile_coord]["timer"] = null
		process_tile(tile_coord)

func process_tile(tile_coord: Vector2):
	var tile :Dictionary = tiles[tile_coord]
	
	match tile["stage"]:
		GROWTH_STAGES.EMPTY:
			tile["stage"] = GROWTH_STAGES.GROWING
			print("tile has reached stage 1 and is growing")
		GROWTH_STAGES.GROWING:
			tile["stage"] = GROWTH_STAGES.MATURED
			print("tile has reached stage 2 and is collectable")
		GROWTH_STAGES.MATURED:
			tile["stage"] = GROWTH_STAGES.EMPTY
			print("tile has been collected and is now empty")
	
	# process tile based on new stage
	process_sprite(tile_coord)

func process_sprite(tile_coord :Vector2):
	# create a new tile entry for the tile clicked
	var tile :Dictionary = tiles[tile_coord]
	
	# if new stage is empty and the sprite isn't removed, remove the sprite
	if tile["stage"] == GROWTH_STAGES.EMPTY:
		if tile["sprite"] != null:
			tile["sprite"].queue_free()
			tile["sprite"] = null
		return null
	
	# if the sprite is null, create a new sprite
	if tile["sprite"] == null:
		var newSprite = sprites2.duplicate()
		newSprite.position = tile_coord
		$TileFilled.add_child(newSprite)
		tiles[tile_coord]["sprite"] = newSprite
	
	# adjust sprite based on stage
	# sprite sheet breakdown: 
	# hframe 0 = growing
	# hframe 1 = matured
	# hframe 2 = item -> only used in the inventory
	match tile["stage"]:
		GROWTH_STAGES.GROWING:
			tile["sprite"].visible = true
			tile["sprite"].frame_coords = Vector2i(0, tile["produce_key"])
		GROWTH_STAGES.MATURED:
			tile["sprite"].frame_coords = Vector2i(1, tile["produce_key"])
