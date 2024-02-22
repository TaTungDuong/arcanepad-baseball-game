# YOUR CUSTOM EVENTS
class_name Events

class PadSelectEvent extends AEvents.ArcaneBaseEvent:
	func _init().(EventName.PadSelect):
		pass
class PadControlEvent extends AEvents.ArcaneBaseEvent:
	var direction: int
	func _init(_direction: int).(EventName.PadControl):
		direction = _direction

class StartEvent extends AEvents.ArcaneBaseEvent:
	func _init().(EventName.Start):
		pass

class TutorialsEvent extends AEvents.ArcaneBaseEvent:
	func _init().(EventName.Tutorials):
		pass

class QuitEvent extends AEvents.ArcaneBaseEvent:
	func _init().(EventName.Quit):
		pass

class FullscreenEvent extends AEvents.ArcaneBaseEvent:
	func _init().(EventName.Fullscreen):
		pass

class PauseEvent extends AEvents.ArcaneBaseEvent:
	func _init().(EventName.Pause):
		pass
	
class ResumeEvent extends AEvents.ArcaneBaseEvent:
	func _init().(EventName.Resume):
		pass

class ConfirmEvent extends AEvents.ArcaneBaseEvent:
	func _init().(EventName.Confirm):
		pass

class GameOverEvent extends AEvents.ArcaneBaseEvent:
	func _init().(EventName.GameOver):
		pass




