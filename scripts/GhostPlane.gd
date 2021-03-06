extends Position3D

onready var plane_node = get_node("/root/World/Plane")
onready var mesh_node = get_node("Mesh")
var track = null
var track_index = 0
var aileron_surface_angle = 0
var elevator_surface_angle = 0
var rudder_surface_angle = 0
const STATE_RECORD = 0
const STATE_PHYSIC = 1
const STATE_ABSENT = 2
var state = STATE_ABSENT

func _ready():
	print("Ghost plane ready")
	plane_node.connect("race_initialized", self, "_on_race_initialized")
	set_physics_process(false)

func _physics_process(delta):
	
	if state == STATE_RECORD and track_index + 10 <= track.size():
		var origin = Vector3(
			track[track_index+0],
			track[track_index+1],
			track[track_index+2]
		)
		var basis = Basis(Quat(
			track[track_index+3],
			track[track_index+4],
			track[track_index+5],
			track[track_index+6]
		))
		aileron_surface_angle = track[track_index+7]
		elevator_surface_angle = track[track_index+8]
		rudder_surface_angle = track[track_index+9]
		mesh_node.set_global_transform(Transform(basis, origin))
		track_index += 10
	elif state == STATE_RECORD:
		var speed = Vector3(
			track[track_index-10+0] - track[track_index-20+0],
			track[track_index-10+1] - track[track_index-20+1],
			track[track_index-10+2] - track[track_index-20+2]
		) / delta
		mesh_node.mode = RigidBody.MODE_RIGID
		mesh_node.set_axis_velocity(speed)
		state = STATE_PHYSIC

func _on_race_initialized(checkpoint_count):
	var recorder = plane_node.get_node("Recorder")
	if recorder.has_best_track():
		track = recorder.best_track["pose"]
		track_index = 0
		mesh_node.mode = RigidBody.MODE_STATIC
		set_physics_process(true)
		visible = true
		state = STATE_RECORD
		print("Best track playing as ghost")
	else:
		set_physics_process(false)
		visible = false
		state = STATE_ABSENT
		print("Ghost disabled")