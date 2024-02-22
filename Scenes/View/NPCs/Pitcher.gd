extends Spatial

var ball

func _ready():
	ball = get_parent().get_node("Ball_RB")
	idle()

func reset():
	ball = get_parent().get_node("Ball_RB")
	idle()

func idle():
	$AnimationPlayer.play("idle")

func shoot():
	$AnimationPlayer.play("shoot")
	get_parent().call_deferred(
		"change_camera",
		true
	)

func start_ball_position():
	ball.call_deferred("start_position")





