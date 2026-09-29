extends Node

var database_location :String = "res://assets/database.json"
var crops_db :Dictionary

func _ready():
	load_database()

func load_database():
	if not FileAccess.file_exists(database_location):
		var error = "Database file is missing in assets."
		push_error(error)
		return
	
	var db_json = read_file(database_location)
	var db_parse = json_parse(db_json)
	
	# Use dictionary keys to assigned database info to proper variables
	load_crops(db_parse.crops)

func read_file(path :String):
	var file = FileAccess.open(path, FileAccess.READ)
	var file_json = file.get_as_text()
	file.close()
	return file_json
	
func json_parse(text :String):
	var json_parser = JSON.new()
	var error = json_parser.parse(text)
	
	if error == OK:
		return json_parser.data
	else: 
		var error_json = "There was an error with the JSON parser within the global script."
		push_error(error_json)
		print(error)
	
func load_crops(db :Dictionary):
	crops_db = db
	
	
