extends Spatial

onready var emissors = $Emissors

const path = "res://assets/resources/textures/monitor/"
var order

func _ready():
	order = 0
	start_loop()

func start_loop():
	while true:
		yield(get_tree().create_timer(5.0), "timeout")
		order = (order + 1) % emissors.get_child_count()
		for c in emissors.get_children():
			if c.name == str(order + 1):
				c.visible = true
			else:
				c.visible = false
		
		
		
