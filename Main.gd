extends Node2D

# names of files in res://Levels
const level_rotation: Array = [
	"1",
]

var _cur_level_index: int = 0
onready var _level_holder: Node2D = $CurrentLevelHolder
onready var _spawned_in: Node2D = $SpawnedIn
onready var _mario = $Mario

func _ready():
	load_level(level_rotation[_cur_level_index])

func load_level(n: String):
	if _level_holder.get_children().size() > 0:
		_level_holder.get_children()[0].queue_free()
	for c in _spawned_in.get_children():
		c.queue_free()
	var new_level: Node2D = _get_pack_from_name(n).instance()
	_level_holder.add_child(new_level)
	_mario.reset()
	_mario.global_position = new_level.get_node("SpawnPosition").global_position

func _get_pack_from_name(n: String): # n is a name of a tscn file in res://Levels
	return load("res://Levels/" + n + ".tscn")

func _on_Mario_dead():
	load_level(level_rotation[_cur_level_index])
