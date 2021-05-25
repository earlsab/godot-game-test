extends KinematicBody2D

const ACCELERATION = 512
const MAX_SPEED = 64
const FRICTION = 0.25
const AIR_RESISTANCE = 0.02
const GRAVITY = 200
const JUMP_FORCE = 120

var motion = Vector2.ZERO

func animation():
	pass


func _physics_process(delta):
	
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if x_input != 0:
			motion.x += x_input * ACCELERATION * delta
			motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
			
	if is_on_floor():
		if x_input == 0:
			motion.x = lerp(motion.x, 0, FRICTION)

		if Input.is_action_just_pressed("ui_up"):
			motion.y = -JUMP_FORCE
	else:
		if x_input == 0:
			motion.x = lerp(motion.x, 0, AIR_RESISTANCE)

	animation()

	motion.y += GRAVITY  * delta

	# TODO UNDERSTAND MOTION_AND_SLIDE()
	motion = move_and_slide(motion, Vector2.UP)

