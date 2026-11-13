extends Control

@export var burger_manager: BurgerManager

@export_group("Params")
@export var name_complexity: int = 5

@export_group("Customer")
@export var customer_label: Label
@export var customer_label_string_prefix: String
@export var customer_label_string_suffix: String

@export_group("Popups")
@export var preview_modal: PreviewPopup
@export var naming_ui: NamingUI

var burger_name: String = ""

func init_loop():
	burger_manager.stacker.clear()

	# Get random burger name. Have to be different from current name
	# Actually not that uncommon.
	burger_name = Generator.make_satisfactory_name(name_complexity, burger_name)
	# Assign burger name to customer
	customer_label.text = " ".join([customer_label_string_prefix, burger_name, customer_label_string_suffix])
	print("|" + customer_label_string_prefix + "|")
	print("|" + burger_name + "|")
	print("|" + customer_label_string_suffix + "|")
	# Assign burger name to preview modal
	preview_modal.target_name = burger_name
	naming_ui.target_name = burger_name
	# I think thats it

func _ready() -> void:
	init_loop()
	preview_modal.next_customer_button.pressed.connect(init_loop)
