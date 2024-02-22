extends Node2D

onready var buttons = $Buttons
var order = 0
var number_of_buttons
export var a = 0.25

func _ready():
	number_of_buttons = $Buttons.get_child_count()

func _process(_delta):
	if visible == false:
		return
	for i in range(number_of_buttons):
		if i == order:
			buttons.get_child(i).modulate = Color(1, 1, 1)
		else:
			buttons.get_child(i).modulate = Color(a, a, a)

func update_order(direction: int):
	if order + direction < 0:
		order = number_of_buttons - 1
	else:
		order = (order + direction) % number_of_buttons

func update_fullscreen():
	if $Buttons/Fullscreen.text == "ON":
		$Buttons/Fullscreen.text = "OFF"
	else:
		$Buttons/Fullscreen.text = "ON"

func update_sfx():
	if $Buttons/SFX.text == "ON":
		$Buttons/SFX.text = "OFF"
	else:
		$Buttons/SFX.text = "ON"
#	$Buttons/SFX.text = "OFF"

func update_vibration():
	if $Buttons/PhoneVibration.text == "ON":
		$Buttons/PhoneVibration.text = "OFF"
	else:
		$Buttons/PhoneVibration.text = "ON"








