extends Node2D

var tile_size = Vector2(16,16)
var tiles :Dictionary = {}

var sprites :Dictionary = {
	"tomato": {
		"stage1": preload("res://assets/food/ghostpixel/01_dish.png"), 
		"stage2": preload("res://assets/food/ghostpixel/04_bowl.png"), 
		"quantity": 6, 
		"value": 1, 
		"time": 60},
}

enum GROWTH_STAGES {
	EMPTY,
	GROWING,
	MATURED
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
			tiles[tile_coord]["produce_key"] = "tomato"
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
	var tile :Dictionary = tiles[tile_coord]
	
	# if new stage is empty and the sprite isn't removed, remove the sprite
	if tile["stage"] == GROWTH_STAGES.EMPTY:
		if tile["sprite"] != null:
			tile["sprite"].queue_free()
			tile["sprite"] = null
		return null
	
	# if the sprite is null, create a new sprite
	if tile["sprite"] == null:
		var newSprite = Sprite2D.new()
		newSprite.scale = Vector2(0.5, 0.5) # using a 32x32 during tests
		newSprite.position = tile_coord
		$TileFilled.add_child(newSprite)
		tiles[tile_coord]["sprite"] = newSprite
	
	# adjust sprite based on stage
	match tile["stage"]:
		GROWTH_STAGES.GROWING:
			tile["sprite"].texture = sprites[tiles[tile_coord]["produce_key"]]["stage1"]
		GROWTH_STAGES.MATURED:
			tile["sprite"].texture = sprites[tiles[tile_coord]["produce_key"]]["stage2"]
