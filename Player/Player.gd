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
	var animationState

	# Movement States
	if Input.is_action_pressed("ui_extra1"):
		moveState = RUN
	elif Input.is_action_pressed("ui_shift"):
		moveState = SWALK
	else:
		moveState = WALK

	# Animation States
	if is_on_floor():
		animationState = "Run"
	else:
		animationState = "Jump"
			
	# Player Input
	if Input.is_action_pressed("ui_right"):
		movement.x = moveState
		$spr_player.flip_h = false
		$spr_player.play(animationState)
	elif Input.is_action_pressed("ui_left"):
		movement.x = -(moveState)
		$spr_player.flip_h = true
		$spr_player.play(animationState)
	else:
		movement.x = 0
		if is_on_floor():
			$spr_player.play("Idle")
		else:
			$spr_player.play("Fall")
	
	# Jump
	if Input.is_action_pressed("ui_jump") and is_on_floor():
		movement.y = JUMP


	movement = move_and_slide(movement, RESISTANCE)
