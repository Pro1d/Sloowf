extends Object

# Elevator at rear of plane, horizontal, centered

var m_action_distance # m
var m_angle_max # rad
var m_key_up # key
var m_key_down # key
var m_joy_axis
var m_force_factor # (m/s, m/s²) to N
var angular_velocity = 0.0 # rad/s
var drag = 0.0
var surface_angle = 0.0
var m_negative_input_factor = 0.6

func _init(action_distance = 6.0, angle_max = PI / 4, force_factor = 0.0001, joy_axis=1, key_up = KEY_UP, key_down = KEY_DOWN):
	m_action_distance = action_distance
	m_angle_max = angle_max
	m_joy_axis = joy_axis
	m_key_up = key_up
	m_key_down = key_down
	m_force_factor = force_factor
	
func read_input():
	var input = -Input.get_joy_axis(0, m_joy_axis)
	if Input.is_key_pressed(m_key_up):
		input += 1
	if Input.is_key_pressed(m_key_down):
		input -= 1
	return input if input < 0 else input * m_negative_input_factor

func angle(input):
	return input * m_angle_max

func reset():
	drag = 0
	angular_velocity = 0
	surface_angle = 0

func update(wind_velocity, delta):
	surface_angle = angle(read_input())
	var s = sin(surface_angle)
	var c = cos(surface_angle)
	var wind_load_coefficient = s # .
	var wind_force_magnitude = wind_load_coefficient * wind_velocity * m_force_factor # N
	drag = wind_load_coefficient * s * wind_velocity * wind_velocity # N
	var lever = c * wind_force_magnitude # N
	
	angular_velocity = lever * m_action_distance # N.m
	
	# non physic: rotating surface force against static surface force
	# -> the forces struggle and converge to a pitch velocity
	# angular_velocity *= 1 # moment of inertia = 1
