class_name PreviewPopup
extends Control

@export_group("Config Mangers")
@export var burger_manager: BurgerManager
@export var naming_ui: NamingUI

@export_group("Config UI Elements")
# @export var open_modal_button: BaseButton
@export var confirm_ui: ConfirmPopup
@export var close_buttons: Array[Button]

@export var burger_match_container: Container
@export var burger_mismatch_container: Container

@export var next_customer_button: BaseButton
@export var explain_naming_button: BaseButton

@export var burger_img_displays: RichTextLabel
@export var burger_name_displays: Array[RichTextLabel]
@export var target_name_displays: RichTextLabel

@export_group("Runtime")
@export var target_name: String

func open():
	visible = true
	var bstack = burger_manager.stacker.stack_string
	var stack_name: String = Parser.greedy_parse(bstack).get_name()
	var stack_imgs = naming_ui.make_stack_bbstring(burger_manager.stacker.stack_string, 16)

	print("Target name ", target_name, " vs auto name ", stack_name)

	burger_img_displays.text = stack_imgs
	for label in burger_name_displays:
		label.text = stack_name
	target_name_displays.text = target_name

	if target_name == stack_name:
		burger_match_container.visible = true
		burger_mismatch_container.visible = false
	else:
		burger_match_container.visible = false
		burger_mismatch_container.visible = true

func close():
	visible = false

func _ready() -> void:
	visible = false
	for c in close_buttons:
		c.pressed.connect(func():
			visible = false
			burger_manager.stacker.pop_top()
		)
	confirm_ui.confirm_button.pressed.connect(open)
	explain_naming_button.pressed.connect(func():
		close()
		naming_ui.open(burger_manager.stacker.stack_string)
	)
