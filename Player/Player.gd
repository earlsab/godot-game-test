extends KinematicBody2D

const ACCELERATION = 512
const MAX_SPEED = 64
const FRICTION = 0.25
const AIR_RESISTANCE = 0.02
const GRAVITY = 200
const JUMP_FORCE = 120

onready var spr_player = $spr_player
var motion = Vector2.ZERO

func _physics_process(delta):

	# Handles Left & Right Input
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	# Processes Input and changes motion.x accordingly
	if x_input != 0:
			motion.x += x_input * ACCELERATION * delta
			motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
					
	# Processes if Jump is possible
	if is_on_floor():
		if x_input == 0:
			# Introduces Ground Friction
			motion.x = lerp(motion.x, 0, FRICTION)
		if Input.is_action_just_pressed("ui_up"):
			motion.y = -JUMP_FORCE
	else:
		if x_input == 0:
			# Introduces Air Friction
			motion.x = lerp(motion.x, 0, AIR_RESISTANCE)

	motion.y += GRAVITY * delta

	# TODO UNDERSTAND MOTION_AND_SLIDE()
	motion = move_and_slide(motion, Vector2.UP)
	animation_now(x_input, motion.y)
	debugger(motion)

func animation_now(x, y):
	# Animation Management for Simple Movement
	# TODO
	# [/] Idle
	# [/] Running
	# [] Variable Idle
	# [] Variable Run Speed
	# [] Idle Crouch
	# [] Moving Crouch
	
	if x == 0 and y == 0:
		spr_player.play("Idle")
	else:
		if y < 0:
			spr_player.play("Jump")
		elif y > 0:
			spr_player.play("Fall")
		elif x != 0:
			spr_player.play("Run")
		spr_player.flip_h = x < 0
			
	


func debugger(m):
	$debug.set_text(str(m))

func animation_later():
	# Purpose allows for expandibility for skill animations
	pass