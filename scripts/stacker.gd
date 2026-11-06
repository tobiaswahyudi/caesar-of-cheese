@tool
class_name Stacker
extends Node3D

@export var ingredient_scene: PackedScene

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
	var scene = ingredient_scene.instantiate() as Ingredient3D
	scene.ingredient = entry
	add_child(scene)
	# node_stack.append(scene)

func remove_current_selected_ingredient():
	if selected_node == null:
		return
	selected_node.queue_free()
	selected_node = null

func _ready() -> void:
	pass
	#for entry in list.list:
		#for i in range(ingredient_repeat):
			#var scene = ingredient_scene.instantiate() as Ingredient3D
			#scene.ingredient = entry
			#add_child(scene)
			#node_stack.append(scene)

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
