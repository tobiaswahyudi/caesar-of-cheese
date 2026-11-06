extends Node3D

@export var ingredient_list: IngredientList
@export var stacker: Stacker
@export var buttons: Array[BaseButton]

func make_callback(ingredient_idx: int):
	return func():
		stacker.add_ingredient(ingredient_list.list[ingredient_idx])

func _ready() -> void:
	for i in range(len(buttons)):
		buttons[i].pressed.connect(make_callback(i))
