extends Control

@export_group("Buttons")
@export var single_ingredient_button: Button
@export var cheeseburger_button: Button
@export var cheese_sandwich_button: Button
@export var hamburger_button: Button
@export var lettuce_button: Button
@export var burger_button: Button
@export var undo_button: Button
@export var done_button: Button
@export var repeat_buttons: Array[Button]

var is_splitting: bool = false
var split_pos: int = 1

@export var initiate_split_button: Button
@export var split_controls_container: Control
@export var split_left_button: Button
@export var split_right_button: Button
@export var execute_split_button: Button
@export var cancel_split_button: Button

@export_group("Display Elements")
@export var total_stack_label: RichTextLabel
@export var current_stack_label: RichTextLabel
@export var stack_name_label: RichTextLabel
@export var current_stack_label_width: int

@export_group("Display Configs")
@export_subgroup("Strings")
@export var undo_label: String = "Undo ↻"
@export_multiline var back_label: String = "← Back\nto burger editing "
@export_multiline var done_editing_label: String
@export var split_cursor: String = " 🔪 "

@export_subgroup("Sizes")
@export var total_stack_label_img_size: int = 28
@export var current_stack_label_img_size: int = 40

@export_subgroup("Img Paths")
@export_file("*.png") var img_path_bun: String
@export_file("*.png") var img_path_patty: String
@export_file("*.png") var img_path_cheese: String
@export_file("*.png") var img_path_lettuce: String

var img_path_map: Dictionary[String, String]
@export_group("Runtime")
@export var total_stack: String
@export var current_stack: String

var total_bst: Parser.BST

var bst_history: Array[Parser.BST] = []

var done_naming: bool:
	get():
		return current_stack == ""

func highlight_bbstring(string: String):
	return "[bgcolor=yellow]" + string + "[/bgcolor]"

func make_ingredient_bbstring(ingredient_letter: String, img_size: int = 40) -> String:
	return "[img={0}]{1}[/img]".format([img_size, img_path_map[ingredient_letter]])

func make_stack_bbstring(stack: String, img_size: int = 40, break_lines: bool = false) -> String:
	print("get bbstring for stack ", stack)
	var total_string = ""
	for letter in stack.split():
		if len(total_string) and break_lines:
			total_string += '\n'
		total_string += make_ingredient_bbstring(letter, img_size)
	return total_string

func eval_button_state() -> void:
	single_ingredient_button.disabled = done_naming or is_splitting or not Parser.check_rule_single(current_stack)
	cheeseburger_button.disabled = done_naming or is_splitting or not Parser.check_rule_cheeseburger(current_stack)
	cheese_sandwich_button.disabled = done_naming or is_splitting or not Parser.check_rule_cheese_sandwich(current_stack)
	hamburger_button.disabled = done_naming or is_splitting or not Parser.check_rule_hamburger(current_stack)
	lettuce_button.disabled = done_naming or is_splitting or not Parser.check_rule_lettuce(current_stack)
	burger_button.disabled = done_naming or is_splitting or not Parser.check_rule_burger(current_stack)

	initiate_split_button.disabled = done_naming or is_splitting
	undo_button.disabled = len(bst_history) == 0

	done_button.disabled = not done_naming
	for idx in range(len(repeat_buttons)):
		var button = repeat_buttons[idx]
		var repeat_count = idx + 2
		button.disabled = done_naming or not Parser.check_rule_repeat(current_stack, repeat_count)

	split_controls_container.visible = is_splitting
	# split_left_button.disabled = never
	# split_right_button.disabled = never
	# execute_split_button.disabled = never
	# cancel_split_button.disabled = never

func update_displays() -> void:
	total_stack_label.text = make_stack_bbstring(total_stack, total_stack_label_img_size, true)
	if len(current_stack) != 0:
		@warning_ignore("integer_division")
		var current_stack_img_size = min(current_stack_label_img_size, current_stack_label_width / (len(current_stack) + 1))
		if is_splitting:
			var stack_first = make_stack_bbstring(current_stack.substr(0, split_pos), current_stack_img_size)
			var stack_rest = make_stack_bbstring(current_stack.substr(split_pos), current_stack_img_size)
			current_stack_label.text = stack_first + split_cursor + stack_rest
		else:
			current_stack_label.text = make_stack_bbstring(current_stack, current_stack_img_size)
	else:
		current_stack_label.text = done_editing_label

	var count: Array[int] = [0]
	stack_name_label.text = total_bst.get_name(func(stack):
		count[0] += 1
		var stack_bbstring = make_stack_bbstring(stack, 24, false)
		if count[0] == 1:
			return highlight_bbstring(stack_bbstring)
		return stack_bbstring
	)

func eval_state() -> void:
	eval_button_state()
	update_displays()

func eval_current_from_bst() -> void:
	var next_unresolved = total_bst.first_unresolved_child()
	if next_unresolved == null:
		# Done naming!!
		current_stack = ""
	else:
		current_stack = next_unresolved.substring
	print("on tree ", total_bst.get_repr(), " next unresolved is: ",current_stack)
	eval_state()

func apply_resolve_bst(bst: Parser.BST):
	bst_history.append(total_bst.deep_clone())

	if total_bst.is_directly_unresolved():
		total_bst = bst
	else:
		print("Before resolve: ", total_bst.get_repr())
		total_bst.resolve_first(bst)
		print("After resolve: ", total_bst.get_repr())
	eval_current_from_bst()

func make_button_click_action(do_one_step_and_get_bst: Callable) -> Callable:
	return func():
		var resolved_bst = do_one_step_and_get_bst.call(current_stack)
		# print("resolving bst for burger resolved to ", resolved_bst.get_name(), ", aka ", resolved_bst.get_repr())
		apply_resolve_bst(resolved_bst)

func make_button_click_parameterized_action(param: int, do_one_step_and_get_bst: Callable) -> Callable:
	return func():
		var resolved_bst = do_one_step_and_get_bst.call(param, current_stack)
		# print("resolving bst for repeat ", param, " resolved to ", resolved_bst.get_name(), ", aka ", resolved_bst.get_repr())
		apply_resolve_bst(resolved_bst)

func undo_history() -> void:
	if len(bst_history) == 0:
		return
	var back_hist = bst_history.pop_back()
	total_bst = back_hist
	eval_current_from_bst()

func _ready() -> void:
	img_path_map = {
		Type.IngredientLetter[Ingredient.IngredientType.Bun]: img_path_bun,
		Type.IngredientLetter[Ingredient.IngredientType.Patty]: img_path_patty,
		Type.IngredientLetter[Ingredient.IngredientType.Cheese]: img_path_cheese,
		Type.IngredientLetter[Ingredient.IngredientType.Lettuce]: img_path_lettuce
	}
	current_stack = total_stack
	total_bst = Parser.BSTUnresolved.new(total_stack, [])
	eval_state()

	single_ingredient_button.pressed.connect(make_button_click_action(Parser.do_resolve_base_burger))
	cheeseburger_button.pressed.connect(make_button_click_action(Parser.do_resolve_base_burger))
	cheese_sandwich_button.pressed.connect(make_button_click_action(Parser.do_resolve_base_burger))
	hamburger_button.pressed.connect(make_button_click_action(Parser.do_resolve_base_burger))

	# lettuce_button.pressed.connect()
	burger_button.pressed.connect(make_button_click_action(Parser.do_one_step_burger))

	for idx in len(repeat_buttons):
		var button = repeat_buttons[idx]
		var repeat_count = idx + 2
		button.pressed.connect(make_button_click_parameterized_action(repeat_count, Parser.do_one_step_repeat))

	undo_button.pressed.connect(undo_history)

	initiate_split_button.pressed.connect(func():
		is_splitting = true
		split_pos = 1
		eval_state()
	)
	split_left_button.pressed.connect(func():
		split_pos = max(1, split_pos - 1)
		eval_state()
	)
	split_right_button.pressed.connect(func():
		split_pos = min(len(current_stack) - 1, split_pos + 1)
		eval_state()
	)
	execute_split_button.pressed.connect(func():
		is_splitting = false
		var resolved_bst = Parser.do_one_step_split(split_pos, current_stack)
		apply_resolve_bst(resolved_bst)
		eval_state()
	)
	cancel_split_button.pressed.connect(func():
		is_splitting = false
		eval_state()
	)
