extends Node2D

class_name MultiPlayer

func play(stream: AudioStream, spatial: bool = false):
	var type_to_add = AudioStreamPlayer
	if spatial:
		type_to_add = AudioStreamPlayer2D
	var a = type_to_add.new()
	add_child(a)
	a.stream = stream
	a.play()
