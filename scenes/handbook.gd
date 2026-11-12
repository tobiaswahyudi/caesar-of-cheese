@tool
class_name Handbook
extends Control

@export var pages: Array[PackedScene]
@export var prev_page_button: BaseButton
@export var next_page_button: BaseButton

@export var left_page_number: Label
@export var right_page_number: Label

@export var left_page_container: Container
@export var right_page_container: Container

@export var left_page_sheet: PanelContainer
@export var right_page_sheet: PanelContainer

@export var close_button: BaseButton
@export var open_button: BaseButton

var num_pages: int:
	get():
		return len(pages)

# 0 indexed, printed page number needs to be added 1
var current_right_page_index: int = 0

func make_page_number_string(num: int) -> String:
	return '  {0}  \n'.format([num])

func instantiate_page(idx: int, container: Container, page_number: Label) -> void:
	var page = pages[idx].instantiate()
	container.add_child(page)
	page_number.text = make_page_number_string(idx + 1)

func render() -> void:
	for c in left_page_container.get_children():
		c.queue_free()
	for c in right_page_container.get_children():
		c.queue_free()
	if current_right_page_index > 1:
		instantiate_page(current_right_page_index - 1, left_page_container, left_page_number)
		left_page_sheet.visible = true
	else:
		left_page_sheet.visible = false

	if current_right_page_index < num_pages:
		instantiate_page(current_right_page_index, right_page_container, right_page_number)
		right_page_sheet.visible = true
	else:
		right_page_sheet.visible = false
	prev_page_button.disabled = current_right_page_index == 0
	next_page_button.disabled = current_right_page_index == num_pages - 1

func prev_page():
	current_right_page_index -= 2
	render()

func next_page():
	current_right_page_index += 2
	render()

func open():
	visible = true

func _ready() -> void:
	render()
	prev_page_button.pressed.connect(prev_page)
	next_page_button.pressed.connect(next_page)
	close_button.pressed.connect(func():
		visible = false
	)
	open_button.pressed.connect(open)

@export_tool_button("Prev page") var a = prev_page
@export_tool_button("Next page") var b = next_page
