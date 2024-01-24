class_name MouseRaycast extends Camera3D

var mouse = Vector2()
var result = null

func _input(event):
	if event is InputEventMouse:
		mouse = event.position

func _process(delta):
	get_selection()

func get_selection():
	var worldspace = get_world_3d().direct_space_state
	var start = project_ray_origin(mouse)
	var end = project_position(mouse, 20000)
	result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(start, end))
