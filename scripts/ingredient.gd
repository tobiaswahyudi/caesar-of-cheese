class_name Ingredient
extends Resource

enum IngredientType {
	Bun,
	Patty,
	Cheese,
	TopBun,
	Lettuce
}

@export var type: IngredientType
@export var scene: PackedScene
@export var height: float
