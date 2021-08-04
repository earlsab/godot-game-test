extends KinematicBody2D

const ACCELERATION = 512
const MAX_SPEED = 64
const FRICTION = 0.25
const AIR_RESISTANCE = 0.02
const GRAVITY = 200
const JUMP_FORCE = 120

var MOVE_ADJUST
var motion = Vector2.ZERO
var click_pos = Vector2()
onready var bullet_time_filter = get_node("/root/Main/HUD/BulletTimeIndicator")
onready var error_filter = get_node("/root/Main/HUD/ErrorIndicator")
onready var spr_player = $spr_player
onready var movement_input = {}
onready var skill_input = {}
onready var basic_animation_ignore = false
onready var skill = false
onready var gravity_ignore = false

func _unhandled_input(event):
	if event.is_action_pressed('ui_click'):
		click_pos = get_global_mouse_position()

# func _process(delta):
# 	pass

func _physics_process(delta):
	# Handles Important Input
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var y_input = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	# Handles Extra Input
	movement_input.Crouch = true if Input.is_action_pressed("ui_down") else false
	skill_input.Teleport = true if Input.is_action_pressed("ui_space") else false

	# Processes Input and changes motion.x accordingly
	if x_input != 0:
			motion.x += x_input * ACCELERATION * delta
			motion.x = clamp(motion.x, (-(MAX_SPEED + MOVE_ADJUST)), (MAX_SPEED + MOVE_ADJUST))
	

	if not gravity_ignore:
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
		

	elif gravity_ignore:
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
	c_animations(x_input, motion.y, movement_input)

	# VAR ADJUSTMENTS
	c_adjust_movespeed(movement_input)

	# SKILLS
	c_skills(x_input, motion.y, skill_input)

func c_animations(x, y, mI) -> void:
	var idle
	var move
	basic_animation_ignore = true if skill == true else false

	if basic_animation_ignore == false:
		if mI.Crouch == true:
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


func c_adjust_movespeed(mI) -> void:
	MOVE_ADJUST = -32 if mI.Crouch == true and is_on_floor() else 0
		
func c_skills(x, y, sI) -> void:
	# This area is hard coded; Needs better implementation
	if sI.Teleport == true:
		if x == 0 and y == 0:
			# Teleport 
			bullet_time_filter.visible = true
			error_filter.visible = false
			self.position = click_pos
			
		else:
			# Teleport error
			error_filter.visible = true
			bullet_time_filter.visible = false
			pass
	elif sI.Teleport == false:
		# Either go teleport or cancel
		bullet_time_filter.visible = false
		error_filter.visible = false
		
	
	# if eI.Teleport == true:
	# 	spr_player.play("SkillTeleA")
	# 	skill = true
	# 	# gravity_ignore = true
	# 	$cam_player.smoothing_speed = 7

	# elif eI.Teleport == false and skill == true:
	# 	spr_player.play("SkillTeleB")


func _on_spr_player_animation_finished() -> void:
	if skill_input.Teleport == false and skill == true:
		skill = false
		# gravity_ignore = false
		$cam_player.smoothing_speed = 1
		
