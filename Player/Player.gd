extends KinematicBody2D

const ACCELERATION = 512
const MAX_SPEED = 64
const FRICTION = 0.25
const AIR_RESISTANCE = 0.02
const GRAVITY = 200
const JUMP_FORCE = 120

var MOVE_ADJUST
var motion = Vector2.ZERO
onready var spr_player = $spr_player
onready var extraInput = {}


func _physics_process(delta):
	# Handles Important Input
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	# Handles Extra Input
	extraInput.Crouch = true if Input.is_action_pressed("ui_down") else false

	# Processes Input and changes motion.x accordingly
	if x_input != 0:
			motion.x += x_input * ACCELERATION * delta
			motion.x = clamp(motion.x, (-(MAX_SPEED + MOVE_ADJUST)), (MAX_SPEED + MOVE_ADJUST))

	# Friction & Jump Input
	if is_on_floor():
		if x_input == 0:
			# Introduces Ground Friction
			motion.x = lerp(motion.x, 0, FRICTION)
		if Input.is_action_just_pressed("ui_up"):
			motion.y = -JUMP_FORCE
	else:
		if x_input == 0:
			motion.x = lerp(motion.x, 0, AIR_RESISTANCE)

	motion.y += GRAVITY * delta

	# TODO UNDERSTAND MOTION_AND_SLIDE()
	motion = move_and_slide(motion, Vector2.UP)

	# ANIMATION
	c_animation(x_input, motion.y, extraInput)

	# VAR ADJUSTMENTS
	c_adjust_movespeed(x_input, motion.y, extraInput)


func c_animation(x, y, eI):
	var idle
	var move

	if eI.Crouch == true:
		idle = "CrouchIdle"
		move = "CrouchMove"
	else:
		# Assumes Standing
		idle = "Idle"
		move = "Run"

	if x == 0 and y == 0:
		spr_player.play(idle)
	else:
		if y < 0:
			spr_player.play("Jump")
		elif y > 0:
			spr_player.play("Fall")
		elif x != 0:
			spr_player.play(move)
		spr_player.flip_h = x < 0


func c_adjust_movespeed(x, y, eI):
	if eI.Crouch == true and y == 0:
		MOVE_ADJUST = -32
	else:
		MOVE_ADJUST = 0