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
onready var basicAnimationIgnore = false
onready var skill = false
onready var gravityIgnore = false

func _physics_process(delta):
	# Handles Important Input
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var y_input = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	# Handles Extra Input
	extraInput.Crouch = true if Input.is_action_pressed("ui_down") else false
	extraInput.Teleport = true if Input.is_action_pressed("ui_space") else false

	# Processes Input and changes motion.x accordingly
	if x_input != 0:
			motion.x += x_input * ACCELERATION * delta
			motion.x = clamp(motion.x, (-(MAX_SPEED + MOVE_ADJUST)), (MAX_SPEED + MOVE_ADJUST))
	

	if not gravityIgnore:
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
		
		# Gravity
		motion.y += GRAVITY * delta
		# TODO UNDERSTAND MOTION_AND_SLIDE()
		

	elif gravityIgnore:
		if x_input == 0:
			# Introduces Ground Friction
			motion.x = lerp(motion.x, 0, FRICTION)
		if y_input == 0:
			# Introduces Ground Friction
			motion.y = lerp(motion.y, 0, FRICTION)
		if y_input != 0:
			motion.y += y_input * ACCELERATION * delta
			motion.y = clamp(motion.y, -MAX_SPEED, MAX_SPEED)

	motion = move_and_slide(motion, Vector2.UP)

	# ANIMATION
	c_animations(x_input, motion.y, extraInput)

	# VAR ADJUSTMENTS
	c_adjust_movespeed(extraInput)

	# SKILLS
	c_skills(x_input, motion.y, extraInput)


func c_animations(x, y, eI):
	var idle
	var move
	basicAnimationIgnore = true if skill == true else false

	if basicAnimationIgnore == false:
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


func c_adjust_movespeed(eI):
	MOVE_ADJUST = -32 if eI.Crouch == true and is_on_floor() else 0
		

func c_skills(x, y, eI):
	if eI.Teleport == true:
		spr_player.play("SkillTeleA")
		skill = true
		# gravityIgnore = true
		$cam_player.smoothing_speed = 7

	elif eI.Teleport == false and skill == true:
		spr_player.play("SkillTeleB")


func _on_spr_player_animation_finished():
	if extraInput.Teleport == false and skill == true:
		skill = false
		# gravityIgnore = false
		$cam_player.smoothing_speed = 1
		