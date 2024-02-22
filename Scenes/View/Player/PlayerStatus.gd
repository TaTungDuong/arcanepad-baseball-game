extends Node2D

export var balls = 3
export var foul_ball = false
export var score = 0

export var fullscreen = false
export var sfx = true
export var phone_vibration = 1

func _ready():
	balls = 3
	foul_ball = false
	score = 0

func reset():
	balls = 3
	foul_ball = false
	score = 0
