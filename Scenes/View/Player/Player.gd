extends Node

var pad:ArcanePad
var padQuaternion = Quat()
onready var bonkSound:AudioStreamPlayer = get_child(2)
onready var confirm = $Confirm
onready var pause = $Pause
onready var result = $Result
onready var tutorials = $Tutorials
onready var settings = $Settings
onready var fireworks = $Result/Sprites/Fireworks
onready var score = $Result/Score/Score
onready var highest_score = $Result/Score/HighestScore
onready var trophies_score = $Result/Score/Trophies
onready var max_distance = $Result/Distance/Distance
onready var highest_distance = $Result/Distance/HighestDistance
onready var trophies_distance = $Result/Distance/Trophies
onready var animation = $AnimationPlayer
var ui = []
var start
var ball
var pitcher

func initialize(_pad:ArcanePad) -> void:
	
	prints("Pad user", _pad.user.name, "initialized")
	pad = _pad
	
	# ASK FOR DEVICE ROTATION AND POINTER
	pad.startGetQuaternion()
	
	# warning-ignore:RETURN_VALUE_DISCARDED
	pad.connect(AEventName.GetQuaternion, self, 'onGetQuaternion')
		
	# LISTEN CUSTOM EVENT FROM PAD
	pad.addSignal(EventName.PadSelect)
	pad.addSignal(EventName.PadControl)
	pad.addSignal(EventName.Start)
	pad.addSignal(EventName.Tutorials)
	pad.addSignal(EventName.Fullscreen)
	pad.addSignal(EventName.Pause)
	pad.addSignal(EventName.Resume)
	pad.addSignal(EventName.Confirm)
	pad.addSignal(EventName.Quit)

	# warning-ignore:return_value_discarded
	pad.connect(EventName.PadSelect, self, "PadSelect")
	# warning-ignore:return_value_discarded
	pad.connect(EventName.PadControl, self, "PadControl")
	# warning-ignore:return_value_discarded
	pad.connect(EventName.Start, self, "Start")
	# warning-ignore:return_value_discarded
	pad.connect(EventName.Tutorials, self, "Tutorials")
	# warning-ignore:return_value_discarded
	pad.connect(EventName.Fullscreen, self, "Fullscreen")
	# warning-ignore:return_value_discarded
	pad.connect(EventName.Pause, self, "Pause")
	# warning-ignore:return_value_discarded
	pad.connect(EventName.Resume, self, "Resume")
	# warning-ignore:return_value_discarded
	pad.connect(EventName.Confirm, self, "Confirm")
	# warning-ignore:return_value_discarded
	pad.connect(EventName.Quit, self, "Quit")
	
func _ready():
#	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	ui = [
		start,
		confirm,
		pause,
		result,
		tutorials,
		settings,
	]
	disable_ui()
	start.visible = true
	pad.calibrateQuaternion()
	for b in $Balls.get_children():
		b.visible = true
	animation.play("RESET")

func reset():
	disable_ui()
	pad.calibrateQuaternion()
	for b in $Balls.get_children():
		b.visible = true
	animation.play("RESET")

func disable_ui():
	for c in ui:
		c.visible = false

func _process(_delta):
	self.transform.basis = Basis(padQuaternion)
	for b in $Balls.get_children():
		if b.name.to_int() > PlayerStatus.balls:
			b.visible = false
		else:
			b.visible = true
	
func _exit_tree():
	pad.queue_free()
	
	
func onGetQuaternion(q):
	if get_tree().paused == true:
		return
	padQuaternion.x = -q.x
	padQuaternion.y = -q.y
	padQuaternion.z = q.z
	padQuaternion.w = q.w

func onOpenArcaneMenu(_e):
	print('Menu opened by ', pad.user.name)
	
func onCloseArcaneMenu(_e):
	print('Menu closed by ', pad.user.name)

		
func _on_Bat_body_entered(_body):
	pad.vibrate(80 * PlayerStatus.phone_vibration)
	bonkSound.play()

func PadSelect(_e):
	#Check Pausable
	var can_pause = true
	for c in ui:
		if c.visible == true:
			can_pause = false
	if can_pause == true:
		Pause(pad)
		return
	if pause.visible == true:
		disable_ui()
		if pause.order == 0:
			Resume(pad)
		if pause.order == pause.number_of_buttons - 1:
			Confirm(pad)
	elif start.visible == true:
		disable_ui()
		if start.order == 0:
			Start(pad)
		if start.order == 1:
			Tutorials(pad)
		if start.order == 2:
			Settings(pad)
		if start.order == start.number_of_buttons - 1:
			Confirm(pad)
	elif result.visible == true:
		disable_ui()
		if result.order == 0:
			Start(pad)
		if result.order == 1:
			Tutorials(pad)
		if result.order == 2:
			Settings(pad)
		if result.order == result.number_of_buttons - 1:
			Confirm(pad)
	elif confirm.visible == true:
		disable_ui()
		if confirm.order == 0:
			Quit(pad)
		if confirm.order == confirm.number_of_buttons - 1:
			Resume(pad)
	elif settings.visible == true:
		if settings.order == 0:
			settings.call_deferred("update_fullscreen")
			Fullscreen(pad)
		if settings.order == 1:
			settings.call_deferred("update_sfx")
			PlayerStatus.sfx = not PlayerStatus.sfx
			AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not PlayerStatus.sfx)
		if settings.order == 2:
			settings.call_deferred("update_vibration")
			if PlayerStatus.phone_vibration == 1:
				PlayerStatus.phone_vibration = 0
			else:
				PlayerStatus.phone_vibration = 1
		if settings.order == settings.number_of_buttons - 1:
			disable_ui()
			if PlayerStatus.balls == 0:
				GameOver()
			else:
				_ready()
	elif tutorials.visible == true:
		disable_ui()
		if PlayerStatus.balls == 0:
			GameOver()
		else:
			_ready()
func PadControl(_e):
	#Check Pausable
	var can_pause = true
	for c in ui:
		if c.visible == true:
			can_pause = false
	if can_pause == true:
		return
	for c in ui:
		if c.visible == true:
			c.call_deferred("update_order", _e.direction)

func Start(_e):
	reset()
	PlayerStatus._ready()
	ball.reset()
	pitcher.call_deferred("shoot")
	pad.emit(Events.ResumeEvent.new())
	yield(get_tree().create_timer(4.0), "timeout")
	var can_pause = false
	for c in ui:
		if c.visible == true:
			can_pause = true
	if can_pause == true:
		return
	get_tree().paused = false

func Fullscreen(_e):
	OS.window_fullscreen = not OS.window_fullscreen

func Tutorials(_e):
	get_tree().paused = true
	tutorials.visible = true
	tutorials.order = 1
	animation.play("tutorials")

func Settings(_e):
	disable_ui()
	get_tree().paused = true
	settings.visible = true

func Pause(_e):
	get_tree().paused = true
	pause.visible = true
	pad.emit(Events.PauseEvent.new())

func Resume(_e):
	get_tree().paused = false
	pause.visible = false
	confirm.visible = false
	pad.emit(Events.ResumeEvent.new())

func Confirm(_e):
	get_tree().paused = true
	confirm.visible = true

func Quit(_e):
	get_tree().quit()

func GameOver():	
	pad.emit(Events.GameOverEvent.new())
	pad.vibrate(200 * PlayerStatus.phone_vibration)
	get_tree().paused = true
	result.visible = true
	score.text = str(PlayerStatus.score)
	max_distance.text = str(ball.max_distance) + " M"
	for b in $Balls.get_children():
		b.visible = false
	animation.play("game_over")
	
	var table_of_score = Database.table_of_score()
	if table_of_score.size() == 0:
		highest_score.text = str(PlayerStatus.score)
		Database.update_score(pad.user.name, PlayerStatus.score)
		trophies_score.visible = true
	elif table_of_score[0]["Score"] > PlayerStatus.score:
		highest_score.text = str(table_of_score[0]["Score"])
		trophies_score.visible = false
	else:
		highest_score.text = str(PlayerStatus.score)
		Database.update_score(pad.user.name, PlayerStatus.score)
		trophies_score.visible = true

	var table_of_distance = Database.table_of_distance()
	if table_of_score.size() == 0:
		highest_distance.text = str(ball.max_distance) + " M"
		Database.update_distance(pad.user.name, ball.max_distance)
		trophies_distance.visible = true
	elif table_of_distance[0]["Distance"] > ball.max_distance:
		highest_distance.text = str(table_of_distance[0]["Distance"]) + " M"
		trophies_distance.visible = false
	else:
		highest_distance.text = str(ball.max_distance) + " M"
		Database.update_distance(pad.user.name, ball.max_distance)
		trophies_distance.visible = true
	fireworks.visible = (trophies_score.visible or trophies_distance.visible)





