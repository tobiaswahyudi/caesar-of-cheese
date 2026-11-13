extends Control

@export_group("Params")
@export var name_complexity: int = 5

@export_group("Customer")
@export var customer_label: Label
@export var customer_label_string_prefix: String
@export var customer_label_string_suffix: String

@export_group("Popups")
@export var preview_modal: PreviewPopup
@export var naming_ui: NamingUI

func init_loop():
	# Get random burger name
	var random_name: String = Generator.solve_name(Generator.generate_structurally(name_complexity))

	# Make sure it's a burger
	if not random_name.ends_with(" Burger"):
		random_name += ' Burger'
	# Assign burger name to customer
	customer_label.text = " ".join([customer_label_string_prefix, random_name, customer_label_string_suffix])
	print("|" + customer_label_string_prefix + "|")
	print("|" + random_name + "|")
	print("|" + customer_label_string_suffix + "|")
	# Assign burger name to preview modal
	preview_modal.target_name = random_name
	naming_ui.target_name = random_name
	# I think thats it

func _ready() -> void:
	init_loop()
	preview_modal.next_customer_button.pressed.connect(init_loop)
