extends CharacterBody3D

@export var camera : Camera3D ## In-world camera.
@export var world_camera_anchor : Node3D ## In-world camera anchor. Used for when the camera is following a cinematic path.

@export var walk_speed    : float = 4.0
@export var sprint_speed  : float = 6.2
@export var jump_velocity : float = 4.5
@export var acceleration  : float = 20.0
@export var friction      : float = 15.0

@export_subgroup("Camera Anchor Controls", "camera_")
@export var camera_tilt          : float = 0.0 ## In degrees.
@export var camera_height        : float = 5.0 ## In meters.
@export var camera_depth         : float = 4.0 ## In meters.
@export var camera_angle         : float = 0.0 ## In degrees.
@export var camera_follow_speed  : float = 6.0 ## Multiplied by delta each frame.
@export var camera_turn_speed    : float = 9.0 ## Multiplied by delta each frame.
@export var camera_follow_amount : float = 1.0 ## Amount the camera follows the anchor. 1 is fully.

const BINGUSPEED = 45.0 ## How fast the camera angle is turnt!!

var current_speed : float = walk_speed

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")



func _ready() -> void:
	# set camera anchor position.
	update_camera_anchor(-1.0)
	update_camera()

func _process(delta: float) -> void:
	# make the anchor follow.
	
	if false:
		if Input.is_action_pressed("cameraleft"):
			camera_angle -= BINGUSPEED
		if Input.is_action_pressed("cameraright"):
			camera_angle += BINGUSPEED
	else:
		if Input.is_action_just_pressed("cameraleft"):
			camera_angle -= BINGUSPEED
		if Input.is_action_just_pressed("cameraright"):
			camera_angle += BINGUSPEED
	pass

func _physics_process(delta: float) -> void:
	var wishvel := Vector3.ZERO
	
	# handle jump and gravity.
	if is_on_floor():
		pass
		#if Input.is_action_just_pressed("jumpward"):
			#velocity.y = jump_velocity
	else:
		velocity.y -= gravity * delta

	# recieve input direction and normalize it.
	var input_dir = Input.get_vector("leftward", "rightward", "forward", "backward")
	var direction = (%CamAnchH.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	wishvel.x = direction.x * current_speed
	wishvel.z = direction.z * current_speed
	
	if direction:
		velocity.x = move_toward(velocity.x, wishvel.x, delta * acceleration)
		velocity.z = move_toward(velocity.z, wishvel.z, delta * acceleration)
	else:
		velocity.x = move_toward(velocity.x, wishvel.x, delta * friction)
		velocity.z = move_toward(velocity.z, wishvel.z, delta * friction)

	move_and_slide()
	
	update_camera_anchor(delta)
	update_camera()



func update_camera() -> void:
	if camera:
		var pos  : Vector3 = %CamAnch.global_position
		var rotx : float   = %CamAnch.rotation.x
		var roty : float   = %CamAnch.rotation.y
		var rotz : float   = %CamAnch.rotation.z
		
		if world_camera_anchor:
			pos = lerp(world_camera_anchor.global_position, pos, camera_follow_amount)
			rotx = lerp_angle(world_camera_anchor.rotation.x, rotx, camera_follow_amount)
			roty = lerp_angle(world_camera_anchor.rotation.y, roty, camera_follow_amount)
			rotz = lerp_angle(world_camera_anchor.rotation.z, rotz, camera_follow_amount)
		
		camera.global_position = pos
		camera.rotation.x = rotx
		camera.rotation.y = roty
		camera.rotation.z = rotz

func update_camera_anchor(delta: float) -> void:
	%CamAnchH.position.y = camera_height
	%CamAnchD.position.z = camera_depth
	%CamAnchH.rotation.y = deg_to_rad(camera_angle)
	%CamAnch.position = %CamAnchD.global_position if (delta == -1) else lerp(%CamAnch.position, %CamAnchD.global_position, camera_follow_speed * delta)
	%CamAnch.rotation.x = -atan2(camera_height, camera_depth) if (delta == -1) else lerp_angle(%CamAnch.rotation.x, -atan2(camera_height, camera_depth), camera_turn_speed * delta)
	%CamAnch.rotation.y = deg_to_rad(camera_angle) if (delta == -1) else lerp_angle(%CamAnch.rotation.y, deg_to_rad(camera_angle), camera_turn_speed * delta)
	%CamAnch.rotation.z = deg_to_rad(camera_tilt) if (delta == -1) else lerp_angle(%CamAnch.rotation.z, deg_to_rad(camera_tilt), camera_turn_speed * delta)
