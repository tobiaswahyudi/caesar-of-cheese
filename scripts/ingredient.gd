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
@export var mesh: Mesh
@export var color: Color
@export var height: float
