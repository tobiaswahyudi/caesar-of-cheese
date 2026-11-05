@tool
class_name Ingredient3D
extends RigidBody3D

@export var ingredient: Ingredient

@onready var mesh_instance: MeshInstance3D = $Mesh
@onready var collider: CollisionShape3D = $Collider
var mesh_material: StandardMaterial3D

func _ready() -> void:
	mesh_instance.mesh = ingredient.mesh
	mesh_material = mesh_instance.material_override.duplicate() as StandardMaterial3D
	mesh_instance.material_override = mesh_material
	mesh_material.albedo_color = ingredient.color
	
	var collider_shape: CylinderShape3D = collider.shape.duplicate()
	collider.shape = collider_shape
	collider_shape.height = ingredient.height * 0.9 #magic number
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	mesh_material.emission_enabled = true

func _on_mouse_exited():
	mesh_material.emission_enabled = false
