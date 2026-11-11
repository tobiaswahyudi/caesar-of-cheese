@tool
class_name Stacker
extends Node3D

@export var ingredient_list: IngredientList
@export var ingredient_scene: PackedScene

@export var camera: Camera3D
@export var starting_camera_height: float

@export var camera_displace_min_height: float = 6.5
@export var camera_displace_mult: float = 4

func add_random_ingredient() -> void:
	var rand_idx = stack_count % 3
	# var rand_idx = 2
	add_ingredient(ingredient_list.list[rand_idx])


@export_tool_button("Add random ingredient") var rnd_btn = add_random_ingredient

var stack_count: int = 0
@export var stack_height: float = 0

var stack_string: String:
	get():
		var stkstr: String = ""
		var children: Array[Node] = get_children()
		for n_node in children:
			var node: Ingredient3D = n_node as Ingredient3D
			var ingredient = node.ingredient
			stkstr += Type.IngredientLetter[ingredient.type]
		return stkstr


var selected_node: Ingredient3D = null:
	set(v):
		if selected_node:
			selected_node.selected = false
		selected_node = v
		if selected_node:
			selected_node.selected = true

func add_ingredient(entry: Ingredient) -> void:
	stack_count += 1
	var scene = ingredient_scene.instantiate() as Ingredient3D
	scene.ingredient = entry
	add_child(scene)

func remove_current_selected_ingredient():
	if selected_node == null:
		return
	stack_count -= 1
	selected_node.queue_free()
	selected_node = null

func pop_top():
	var children: Array[Node] = get_children()
	var last_child: Node = children[-1]
	selected_node = last_child
	remove_current_selected_ingredient()

func _ready() -> void:
	camera.position.y = starting_camera_height

func _physics_process(_delta: float) -> void:
	var y: float = 0
	var children: Array[Node] = get_children()
	for n_node in children:
		var node: Ingredient3D = n_node as Ingredient3D
		var ingredient = node.ingredient
		var half_height = ingredient.height * 0.5
		y += half_height
		node.position.y = y
		y += half_height
	stack_height = y
	if stack_height > camera_displace_min_height:
		var cam_displace = (stack_height - camera_displace_min_height) * camera_displace_mult
		camera.position.y = cam_displace + starting_camera_height
