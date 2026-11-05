@tool
extends TextureRect

@export var ingredient_index: int = 0
@export var ingredient_list: IngredientList

@onready var ingredient_3d: Ingredient3D = $SubViewport/Ingredient3D
@onready var subviewport: SubViewport = $SubViewport

func _ready() -> void:
	ingredient_3d.ingredient = ingredient_list.list[ingredient_index]
	texture = subviewport.get_texture()
