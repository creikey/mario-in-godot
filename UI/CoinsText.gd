extends Label

var _mario = null

func assign_mario(p_mario):
	_mario = p_mario

func _process(delta):
	if _mario == null:
		return
	text = str(_mario.coins)
