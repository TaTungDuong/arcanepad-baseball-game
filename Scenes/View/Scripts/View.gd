extends Node

onready var start = $Start

var players := [] 
var gameStarted := false
var playerScene = preload("res://Scenes/View/Player/Player.tscn")

func _ready():
	initView()
	change_camera(true)
	get_tree().paused = true
	start.visible = true

func initView():
	
	Arcane.init()
	
	# LISTEN WHEN THIS CLIENT (THE VIEW) IS INITIALIZED
	Arcane.signals.connect(AEventName.ArcaneClientInitialized, self, "onArcaneClientInitialized")
		
	# LISTEN WHEN ANY GAMEPAD CONNECTS
	Arcane.signals.connect(AEventName.IframePadConnect, self, "onIframePadConnect")
	
	# LISTEN WHEN ANY GAMEPAD DISCONNECTS
	Arcane.signals.connect(AEventName.IframePadDisconnect, self, "onIframePadDisconnect")


# CREATE A PLAYER FOR EACH GAMEPAD THAT WAS CONNECTED BEFORE THE VIEW HAD INITIALIZED
func onArcaneClientInitialized(initialState):
	for pad in initialState.pads:
		createPlayer(pad)


# FOR EACH GAMEPAD THAT CONNECTS, CREATE A PLAYER IF DONT EXIST
func onIframePadConnect(e, _from):
	
	var playerExists = false
	for _player in players:
		if _player.pad.iframeId == e.iframeId:
			playerExists = true
			break
	if playerExists:
		return

	var pad = ArcanePad.new(e.deviceId, e.internalId, e.iframeId, true, e.user)
	createPlayer(pad)


# DESTROY THE PLAYER ON GAMEPAD DISCONNECT (YOU CAN CHANGE THIS LOGIC, FOR EXAMPLE TO PAUSE OR WARN USERS)
func onIframePadDisconnect(e, _from):
	var player = null
	for _player in players:
		if _player.pad.iframeId == e.iframeId:
			player = _player
			break
			
	if player == null:
		push_error("Player not found to remove on disconnect")
		return

	destroy_player(player)


func createPlayer(pad):
	
	# This prevents creating the player if our pad app haven't been loaded
	if pad.iframeId == null || pad.iframeId == "": return
	
	var newPlayer = playerScene.instance()
	print(newPlayer)
	newPlayer.initialize(pad)
	newPlayer.ball = $Ball_RB
	newPlayer.pitcher = $Pitcher
	newPlayer.start = $Start
	add_child(newPlayer)
	players.append(newPlayer)

func destroy_player(player):
	players.erase(player)
	if player:	player.queue_free()

onready var player_camera = $PlayerCamera
onready var ball_camera = $BallCamera/Camera
func change_camera(direction: bool):
	player_camera.current = direction
	ball_camera.current = not direction

func _physics_process(_delta):
	$BallCamera.global_translation = $Ball_RB.global_translation

func vibrate(amount: int):
	for p in players:
		p.pad.vibrate(amount * PlayerStatus.phone_vibration)

func game_over():
	for p in players:
		p.GameOver()
