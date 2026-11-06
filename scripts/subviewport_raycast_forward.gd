extends Camera3D

@export var stacker: Stacker

@export var ray_length: float = 1000.0

func _input(event: InputEvent) -> void:
	if event is not InputEventMouse:
		return
	var mouse_pos = event.position
	shoot_ray(mouse_pos)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		stacker.remove_current_selected_ingredient()

func shoot_ray(mouse_pos: Vector2) -> void:
	var ray_origin = project_ray_origin(mouse_pos)
	var ray_end = ray_origin + project_ray_normal(mouse_pos) * ray_length
	
	# Access the unique 3D physics state of this SubViewport
	var space_state = get_world_3d().direct_space_state
	if space_state == null:
		return
		
	# Create the raycast query
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collide_with_areas = true  # Turn true if selecting Area3D nodes
	query.collide_with_bodies = true # Turn true if selecting Static/RigidBody3D nodes
	
	# Execute the ray intersection
	var result = space_state.intersect_ray(query)
	
	# 4. Handle selection result
	if not result.is_empty():
		var hit_object = result.collider
		print("Selected 3D object inside subviewport: ", hit_object.name, " type ", (hit_object as Ingredient3D).ingredient.type)
		stacker.selected_node = hit_object as Ingredient3D
	else:
		stacker.selected_node = null
