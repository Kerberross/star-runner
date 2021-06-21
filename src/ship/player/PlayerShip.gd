extends AbstractShip


onready var camera_focus := $CameraFocus
onready var checkpoint_line := $CheckpointLine

func _ready() -> void:
	._ready()
	checkpoint_line.global_transform.origin = Vector3.ZERO
	checkpoint_line.set_as_toplevel(true)

func get_target() -> Vector3:
	var space_state := get_world().direct_space_state
	var mouse_position := get_viewport().get_mouse_position()
	var ray_origin := get_viewport().get_camera().project_ray_origin(mouse_position)
	var ray_end := ray_origin + get_viewport().get_camera().project_ray_normal(mouse_position) * 2000
	var target := space_state.intersect_ray(ray_origin, ray_end)
	if not target.empty():
		return target.position
	return Vector3.ZERO

func get_truster_strength() -> float:
	return Input.get_action_strength("forward")

func get_boost() -> bool:
	return Input.is_action_pressed("boost")

func _process(delta: float) -> void:
	._process(delta)
	self.draw_line(checkpoint_line, self.global_transform.origin, self.next_checkpoint.global_transform.origin)
	var focus := self.linear_velocity
	if focus.length() > 20:
		focus = focus.normalized() * 20
	camera_focus.transform.origin = focus * 0.5


func draw_line(im: ImmediateGeometry, start: Vector3, end: Vector3):
	im.clear()
	im.begin(Mesh.PRIMITIVE_POINTS, null)
	im.add_vertex(start)
	im.add_vertex(end)
	im.end()
	im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	im.add_vertex(start)
	im.add_vertex(end)
	im.end()
