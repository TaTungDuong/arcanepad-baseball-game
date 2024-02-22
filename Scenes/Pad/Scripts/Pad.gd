extends Node2D

onready var bat = $Bat
onready var buttons = $Buttons
onready var buttons_control = $Buttons/ButtonsControl
onready var buttons_play = $Buttons/ButtonsPlay

var screen_size

func _ready():
	initPad()
	set_buttons(true)
	screen_size = get_viewport().get_visible_rect().size
	var _center_x = screen_size.x / 2
	var _center_y = screen_size.y / 2
	buttons.rect_size.x = screen_size.y
	buttons.rect_position.x = buttons.rect_size.y
	bat.position.y = _center_y

func set_buttons(value: bool):
	buttons_control.visible = value
	buttons_play.visible = not value

func initPad():
	Arcane.init({'deviceType': 'pad'})

	# LISTEN WHEN THIS CLIENT (GAMEPAD) IS INITIALIZED
	Arcane.signals.connect(AEventName.ArcaneClientInitialized, self, "onArcaneClientInitialized")

func onArcaneClientInitialized(_initialState):
	
	# LISTEN CUSTOM EVENT FROM THE VIEW
	Arcane.signals.addSignal(EventName.GameOver)
	Arcane.signals.addSignal(EventName.Pause)
	Arcane.signals.addSignal(EventName.Resume)
	# warning-ignore:unused_argument
	Arcane.signals.connect(EventName.GameOver, self, "GameOver")
	# warning-ignore:unused_argument
	Arcane.signals.connect(EventName.Pause, self, "Pause")
	# warning-ignore:unused_argument
	Arcane.signals.connect(EventName.Resume, self, "Resume")

func _on_Left_pressed():
	Arcane.msg.emitToViews(Events.PadControlEvent.new(-1))
func _on_Select_pressed():
	Arcane.msg.emitToViews(Events.PadSelectEvent.new())
func _on_Right_pressed():
	Arcane.msg.emitToViews(Events.PadControlEvent.new(1))

func _on_Reset_pressed():
	Arcane.pad.calibrateQuaternion()

func Pause(_e, _from):
	set_buttons(true)
func Resume(_e, _from):
	set_buttons(false)

func GameOver(_e, _from):
	set_buttons(true)
	Arcane.utils.writeToScreen("Game Over")


