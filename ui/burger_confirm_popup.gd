class_name ConfirmPopup
extends Control

@export var burger_manager: BurgerManager
@export var open_modal_button: BaseButton
@export var close_button: Button

@export var confirm_button: Button

@export var burger_display: RichTextLabel
@export var naming_ui: NamingUI

func open():
	visible = true
	burger_display.text = naming_ui.make_stack_bbstring(burger_manager.stacker.stack_string, 16)
	
func _ready() -> void:
	visible = false
	open_modal_button.pressed.connect(open)
	close_button.pressed.connect(func():
		visible = false
		burger_manager.stacker.pop_top()
	)
	confirm_button.pressed.connect(func():
		visible = false
	)
