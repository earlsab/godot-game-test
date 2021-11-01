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
var click_pos_mod

onready var tele_count = get_node("Skill_Countdown")
onready var tele_pos = get_node("/root/Main/HUD/Teleport_Position")
onready var timer = get_node("Skill_Timer")
onready var bullet_time_filter = get_node("/root/Main/HUD/BulletTimeIndicator")
onready var error_filter = get_node("/root/Main/HUD/ErrorIndicator")
onready var spr_player = $spr_player
onready var movement_input = {}
onready var skill_input = {}
onready var basic_animation_ignore = false
onready var skill = false
onready var gravity_ignore = false
onready var skill_enable = false
onready var timer_once = false


func _unhandled_input(event):
	if event.is_action_pressed('ui_click'):
		click_pos = get_global_mouse_position()
		click_pos_mod = click_pos
		
		# TODO Buggy offset feature. Might be setting teleport block based on the map position or self position or something idk
		click_pos_mod.x += 124
		click_pos_mod.y -= 20
		tele_pos.set_position(click_pos_mod)



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
	# So far works by slowing the character down when crouching
	c_adjust_movespeed(movement_input)

	# SKILLS
	# Checks if any skills are toggled
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
	# TODO Teleport to only commence after 5 secs. Add room for future animations.
	# This area is hard coded; Needs better implementation
	if sI.Teleport == true:
		timer.set_wait_time(1)
		tele_pos.visible = true 
		if x == 0 and y == 0: # Checking system... if the character is not moving commit to launching teleportation sequence
			if timer_once == false:	
				timer.start()
				timer_once = true
			if skill_enable == false:
				tele_count.set_text(str(timer.get_time_left()))	
				error_filter.visible = true
			elif skill_enable == true:
				error_filter.visible = false
				bullet_time_filter.visible = true
				self.position = click_pos
			
		else:
			# Teleport error
			timer.stop()
			timer_once = false
			skill_enable = false
			error_filter.visible = true
			tele_pos.visible = false
			bullet_time_filter.visible = false
			pass
	elif sI.Teleport == false:
		# Either go teleport or cancel
		timer_once = false
		tele_count.set_text("")
		timer.stop()
		bullet_time_filter.visible = false
		error_filter.visible = false
		tele_pos.visible = false
		
func _on_spr_player_animation_finished() -> void:
	if skill_input.Teleport == false and skill == true:
		skill = false
		# gravity_ignore = false
		$cam_player.smoothing_speed = 1
	
func _on_Timer_timeout():
	skill_enable = true


	# 	spr_player.play("SkillTeleA")
	# 	skill = true
	# 	# gravity_ignore = true
	# 	$cam_player.smoothing_speed = 7

	# elif eI.Teleport == false and skill == true:
	# 	spr_player.play("SkillTeleB")

