extends KinematicBody2D

const GRAVITY = 20 
const RESISTANCE = Vector2(0, -1)

export var SWALK = 200
export var RUN = 400
export var WALK = 300
export var JUMP = -500
 

# TODO: Update Notion, Vector2 directly changes node's position
var movement = Vector2()

func _physics_process(_delta):
	movement.y += GRAVITY
	var moveState

	# Movement States
	if Input.is_action_pressed("ui_extra1"):
		moveState = RUN
	elif Input.is_action_pressed("ui_shift"):
		moveState = SWALK
	else:
		moveState = WALK
			
	# Player Input
	if Input.is_action_pressed("ui_right"):
		movement.x = moveState
		$spr_player.flip_h = false
		$spr_player.play("Run")
	elif Input.is_action_pressed("ui_left"):
		movement.x = -(moveState)
		$spr_player.flip_h = true
		$spr_player.play("Run")
	else:
		movement.x = 0
		$spr_player.play("Idle")
	
	# Jump
	if Input.is_action_pressed("ui_jump") and is_on_floor():
		movement.y = JUMP
	else:
		pass

	movement = move_and_slide(movement, RESISTANCE)
