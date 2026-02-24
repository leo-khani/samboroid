@tool
class_name OrbitalMovement extends Path2D

@onready var path_follow_2d: PathFollow2D = $PathFollow2D

@export var target: NodePath
@export var orbit_around: NodePath
@export var speed: float = 10
@export var radius: float: 
	set(value):
		radius = value
		_create_path()

func _create_path():
	if not is_node_ready():
		return


	var new_curve = Curve2D.new()
	var points = 64
	for i in range(points):
		var angle = (float(i) / points) * TAU
		var point = Vector2(cos(angle), sin(angle)) * radius
		new_curve.add_point(point)
	self.curve = new_curve
	path_follow_2d.loop = true

func _ready():
	_create_path()
	# Position the orbit center on the target body
	if orbit_around:
		var parent_body = get_node(orbit_around)
		global_position = parent_body.global_position

func _process(delta):
	path_follow_2d.progress += speed * delta
	# Optionally move the orbiting body
	if target:
		var orbiting_body = get_node(target)
		orbiting_body.global_position = path_follow_2d.global_position
