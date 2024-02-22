extends RigidBody

export var is_looping = false
export var reset_time = 11.2
export var reload_time = 4.0

onready var label = $Distance/Label
onready var homerun = $Distance/Homerun
onready var animation = $AnimationPlayer
onready var score = $Score/Score
onready var audio = $AudioStreamPlayer

var initX
var initY
var initZ

var linearVelocity = Vector3(1, 5, 15)
#var angularVelocity = Vector3(15, 0, 5)

var max_distance = 0
var land_count
var is_landed
var is_striked
var muzzle
var pitcher

func _ready():
	muzzle = get_parent().get_node("Muzzle")
	pitcher = get_parent().get_node("Pitcher")
	max_distance = 0
	land_count = 0
	is_landed = false
	is_striked = false
	label.text = ""
	score.text = "0"
	get_parent().call_deferred(
		"change_camera",
		true
	)
	
	initX = translation.x
	initY = translation.y
	initZ = translation.z
	if is_looping == true:
		start_position_loop()
	else:
		start_position()
	linear_velocity = linearVelocity
#	angular_velocity = angularVelocity

func reset():
	max_distance = 0
	land_count = 0
	is_landed = false
	is_striked = false
	label.text = ""
	score.text = "0"
	get_parent().call_deferred(
		"change_camera",
		true
	)
	if is_looping == true:
		start_position_loop()
	else:
		start_position()
	linear_velocity = linearVelocity
#	angular_velocity = angularVelocity

func start_position_loop():
	while true:
		yield(get_tree().create_timer(4.0), "timeout")  # wait for 5 seconds
		translation = Vector3(initX, initY, initZ)  # set the position to (0, 10, 0)
		linear_velocity = linearVelocity
#		angular_velocity = angularVelocity
#		print("Start: " + str(calculate(global_translation)))
		land_count = 0
		is_landed = false
		is_striked = false
		label.text = ""
		get_parent().call_deferred(
			"change_camera",
			true
		)
	PlayerStatus.foul_ball = false

func start_position():
	translation = Vector3(initX, initY, initZ)  # set the position to (0, 10, 0)
	linear_velocity = linearVelocity
#	angular_velocity = angularVelocity
#	print("Start: " + str(calculate(global_translation)))
	land_count = 0
	is_landed = false
	is_striked = false
	label.text = ""
	PlayerStatus.foul_ball = false

var current_transform
func _process(_delta):
	if global_translation.y <= muzzle.global_translation.y + 0.15:
		land_count += 1
	if land_count == 1 and is_landed == false:
		is_landed = true
		if global_translation.z < 0:
			current_transform = global_transform
			animation.play("show")
			if PlayerStatus.foul_ball == false:
				label.text = "%.3f" % calculate_distance() + " m"
				if calculate_distance() > max_distance:
					max_distance = calculate_distance()
				homerun.visible = false
				if calculate_distance() > 115.0:
					homerun.visible = true
			else:
				label.text = "Foul ball!"
				homerun.visible = false
			yield(get_tree().create_timer(reset_time - reload_time), "timeout")
			pitcher.call_deferred("shoot")
			yield(get_tree().create_timer(reload_time), "timeout")
			start_position()
		else:
			homerun.visible = false
			animation.play("show")
			audio.volume_db = -15
			if is_striked == false:
				label.text = "Swing and a miss!"
				PlayerStatus.balls -= 1
				get_parent().vibrate(100)
			else:
				label.text = "Foul ball!"
			if PlayerStatus.balls > 0:
				yield(get_tree().create_timer(reset_time - reload_time), "timeout")
				pitcher.call_deferred("shoot")
				yield(get_tree().create_timer(reload_time), "timeout")
				start_position()
			elif PlayerStatus.balls == 0:
				get_parent().game_over()
		
func calculate_distance():
	return current_transform.origin.distance_to(muzzle.global_transform.origin)

onready var zero = $Point/Zero
onready var bonus = $Point/Bonus
onready var minus = $Point/Minus
var point
func get_point_text():
	point = 0
	if label.text == "Swing and a miss!":
		zero.text = "0"
		bonus.text = ""
		minus.text = ""
		point = 0
	elif label.text == "Foul ball!":
		zero.text = "0"
		bonus.text = ""
		minus.text = ""
		point = 0
	else:
		zero.text = ""
		minus.text = ""
		if calculate_distance() < 10:
			bonus.text = "+0"
			point = 0
		if 10 <= calculate_distance() and calculate_distance() < 20:
			bonus.text = "+1"
			point = 1
		if 20 <= calculate_distance() and calculate_distance() < 40:
			bonus.text = "+2"
			point = 2
		if 40 <= calculate_distance() and calculate_distance() < 60:
			bonus.text = "+4"
			point = 4
		if 60 <= calculate_distance() and calculate_distance() < 100:
			bonus.text = "+8"
			point = 8
		if 100 <= calculate_distance():
			bonus.text = "+16"
			point = 16
			if homerun.visible == true:
				bonus.text = "+32"
				point = 32
func clear_point_text():
	zero.text = ""
	bonus.text = ""
	minus.text = ""
func update_score_text():
	var current_score = PlayerStatus.score
	PlayerStatus.score += point
	if get_tree().paused == true:
		score.text = str(PlayerStatus.score)
	for s in range(current_score, current_score + point + 1):
		yield(get_tree().create_timer(0.01), "timeout")
		score.text = str(s)

func get_audio_stream():
	if label.text == "Swing and a miss!":
		audio.volume_db = -15
		audio.stream = load("res://assets/audio/wav/miss.mp3")
	elif label.text == "Foul ball!":
		audio.volume_db = -15
		audio.stream = load("res://assets/audio/wav/foul_ball.mp3")
	else:
		if calculate_distance() < 10:
			audio.volume_db = -20
			audio.stream = load("res://assets/audio/wav/0-10.mp3")
		if 10 <= calculate_distance() and calculate_distance() < 20:
			audio.volume_db = -10
			audio.stream = load("res://assets/audio/wav/10-20.mp3")
		if 20 <= calculate_distance() and calculate_distance() < 40:
			audio.volume_db = -10
			audio.stream = load("res://assets/audio/wav/20-40.mp3")
		if 40 <= calculate_distance() and calculate_distance() < 60:
			audio.volume_db = -10
			audio.stream = load("res://assets/audio/wav/40-60.mp3")
		if 60 <= calculate_distance() and calculate_distance() < 100:
			audio.volume_db = -10
			audio.stream = load("res://assets/audio/wav/60-100.mp3")
		if 100 <= calculate_distance():
			audio.volume_db = -10
			audio.stream = load("res://assets/audio/wav/100-115.mp3")
			if homerun.visible == true:
				audio.volume_db = -10
				audio.stream = load("res://assets/audio/wav/homerun_cheer.mp3")


func _on_Ball_RB_body_entered(body: Node):
	if body.is_in_group("player"):
		is_striked = true
		yield(get_tree().create_timer(1.0), "timeout")
		get_parent().call_deferred(
			"change_camera",
			false
		)




