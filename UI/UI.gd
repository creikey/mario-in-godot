extends CanvasLayer

export (NodePath) var mario_path

onready var _mario = get_node(mario_path)

func _ready():
	propagate_call("assign_mario", [_mario])
