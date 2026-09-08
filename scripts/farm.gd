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

func _ready():
	# Adds the marker2d into an array to represent the tiles
	var markers = get_node("MarkerList")
	for row in markers.get_children():
		for coord:Marker2D in row.get_children():
			tiles[coord.position] = {"rect": Rect2(coord.position, tile_size), "timer": null, "produce_Key": null, "stage": null, "sprite": null}

# get a tile's center coordinate
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
		if tiles[tile_coord]["stage"] == null: 
			var newTimer: Timer = Timer.new()
			newTimer.wait_time = sprites["tomato"]["time"]/20
			newTimer.one_shot = true
			newTimer.autostart = true
			newTimer.timeout.connect(timer_done.bind(tile_coord))
			tiles[tile_coord]["timer"] = newTimer
			tiles[tile_coord]["produce_key"] = "tomato"
			process_tile(tile_coord)
			$TimerList.add_child(newTimer)
		elif tiles[tile_coord]["stage"] == 1:
			print("in progress...")
		elif tiles[tile_coord]["stage"] == 2:
			process_tile(tile_coord)
	
func timer_done(tile_coord: Vector2):
	if tiles[tile_coord]["timer"] != null:
		tiles[tile_coord]["timer"].queue_free()
		tiles[tile_coord]["timer"] = null
		process_tile(tile_coord)

func process_tile(tile_coord: Vector2):
	var stage = tiles[tile_coord]["stage"]
	
	if stage == null:
		tiles[tile_coord]["stage"] = 1
		print("tile has reached stage 1 and is growing")
	if stage == 1:
		tiles[tile_coord]["stage"] = 2
		print("tile has reached stage 2 and is collectable")
	if stage == 2:
		tiles[tile_coord]["stage"] = null
		print("tile has been collected and is now null")
	process_sprite(tile_coord, tiles[tile_coord]["stage"])

func process_sprite(tile_coord :Vector2, stage):
	
	if (tiles[tile_coord]["sprite"] != null):
			tiles[tile_coord]["sprite"].queue_free()
			tiles[tile_coord]["sprite"] = null
		
	if stage != null: 
		var newSprite = Sprite2D.new()
		if stage == 1: 
			newSprite.texture = sprites[tiles[tile_coord]["produce_key"]]["stage1"]
		elif stage == 2:
			newSprite.texture = sprites[tiles[tile_coord]["produce_key"]]["stage2"]
		newSprite.position = tile_coord
		$TileFilled.add_child(newSprite)
		tiles[tile_coord]["sprite"] = newSprite
	
	print("tile_coord ", tile_coord)
	print("click_coord ", get_local_mouse_position())
	if tiles[tile_coord]["sprite"]: print("sprite_coord" , tiles[tile_coord]["sprite"].position)
