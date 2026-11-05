@tool
extends Node3D

@export var list: IngredientList
var stack: Array[Node3D]

@export var ingredient_repeat: int = 3

func _ready() -> void:
	for entry in list.list:
		for i in range(ingredient_repeat):
			var scene = entry.scene.instantiate()
			add_child(scene)
			stack.append(scene)

func _physics_process(delta: float) -> void:
	var y: float = 0
	for idx in range(len(stack)):
		var node = stack[idx]
		var ingredient_idx = idx / ingredient_repeat
		var ingedient = list.list[ingredient_idx]
		var half_height = ingedient.height * 0.5
		y += half_height
		node.position.y = y
		y += half_height
