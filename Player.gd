extends KinematicBody2D

const GRAVITY = 10
const RESISTANCE = Vector2(0, -1)

export var RUN = 200
export var WALK = 500
export var JUMP = -500

# TODO: Find out the reason why calling for Vector2()
# automatically changes movement
var movement = Vector2()

func _physics_process(_delta):
	movement.y += GRAVITY
	
	# Walk
	if Input.is_action_pressed("ui_right"):
		movement.x = WALK
		$spr_player.flip_h = false
		$spr_player.play("Run")
	elif Input.is_action_pressed("ui_left"):
		movement.x = -(WALK)
		$spr_player.flip_h = true
		$spr_player.play("Run")
	else:
		movement.x = 0
		$spr_player.play("Idle")
	
	# Jump
	if Input.is_action_pressed("ui_up") and is_on_floor():
		movement.y = JUMP
	else:
		pass

	movement = move_and_slide(movement, RESISTANCE)
