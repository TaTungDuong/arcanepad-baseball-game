extends Node2D

onready var label = $Background/Sprites/Label
var order = 1

func _process(_delta):
	label.text = "#" + str(order)
	for p in $Pages.get_children():
		p.visible = (p.name == str(order))

func _on_Video_finished():
	$Pages.get_node("1/Video").play()

func update_order(direction: int):
	if order + direction == 0:
		order = $Pages.get_child_count()
	elif order + direction > $Pages.get_child_count():
		order = 1
	else:
		order += direction




