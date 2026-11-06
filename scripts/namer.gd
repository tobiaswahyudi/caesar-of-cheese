# This is a singleton. There may only be one oracle.
extends Node

class BST:
	var substring: String
	var children: Array[BST]
	var repeat_count: int = 1
	var tuple_names = [
		'',
		'',
		'Double',
		'Triple',
		'Quadruple',
	]
	var tuple_name: String:
		get():
			return str(repeat_count) + 'x' if repeat_count > 4 else tuple_names[repeat_count]

	func max_child_depth() -> int:
		var mx: int = 0
		for c in children:
			mx = max(mx, c.depth())
		return mx

	func depth() -> int:
		return max_child_depth() + 1

	func _init(p_str: String, p_children: Array[BST]) -> void:
		substring = p_str
		children = p_children

	func get_name() -> String:
		return "YOU_SHOULDNT_SEE_THIS(" + substring + ")"

	func get_repr() -> String:
		return substring
	
	func is_ingredient() -> bool:
		return false

	func is_patty_cheese_sequence() -> bool:
		return false

	func is_patty_sequence() -> bool:
		return false

class BSTIngredient extends BST:
	func get_name() -> String:
		var index = Type.IngredientLetter.find(substring)
		if index == -1:
			return 'Nothing'
		return Type.IngredientName[index]

	func is_ingredient() -> bool:
		return true

	func is_patty_sequence() -> bool:
		return substring == Type.IngredientLetter[Ingredient.IngredientType.Patty]

	func depth() -> int:
		return 1

class BSTBurger extends BST:
	func get_name() -> String:
		if children[0].is_patty_sequence():
			return children[0].tuple_name + " Hamburger"
		if children[0].is_patty_cheese_sequence():
			return children[0].tuple_name + " Cheeseburger"
		return children[0].get_name() + " Burger"

	func get_repr() -> String:
		return "[" + children[0].get_repr() + "]"

class BSTSequence extends BST:
	func get_name() -> String:
		var contents_name = ""
		for c in children:
			if len(contents_name) > 0:
				contents_name += " and "
			contents_name += c.get_name()
		return contents_name

	func get_repr() -> String:
		var contents_name = ""
		for c in children:
			if len(contents_name) > 0:
				contents_name += ","
			contents_name += c.get_repr()
		return "(" + contents_name + ")"

	func is_patty_cheese_sequence() -> bool:
		var patty_letter = Type.IngredientLetter[Ingredient.IngredientType.Patty]
		var cheese_letter = Type.IngredientLetter[Ingredient.IngredientType.Cheese]
		return substring == patty_letter + cheese_letter || substring == cheese_letter + patty_letter

	func depth() -> int:
		# disfavor sequences
		return max_child_depth() + 2

class BSTMultiple extends BST:
	func get_name() -> String:
		return tuple_name + ' ' + children[0].get_name()

	func get_repr() -> String:
		return "(" + str(repeat_count) + "x" + children[0].get_repr() + ")"

	func is_patty_cheese_sequence() -> bool:
		return children[0].is_patty_cheese_sequence()

	func is_patty_sequence() -> bool:
		return children[0].is_patty_sequence()

var min_stack_depth_cache: Dictionary[String, int] = {}

func check_rule_burger(string: String) -> bool:
	return RegEx.create_from_string("^B.*B$").search(string) != null
	
func do_rule_burger(string: String) -> String:
	return string.substr(1, len(string) - 2)


func greedy_parse(string: String) -> BST:
	# First check base cases
	var strlen = len(string)
	if strlen <= 1:
		return BSTIngredient.new(string, [])
	if check_rule_burger(string):
		var insides = do_rule_burger(string)
		return BSTBurger.new(insides, [greedy_parse(insides)])

	# Check repeats, start with the most first.
	for tgt_repeat in range(4, 1, -1):
		# print(string," w len ",strlen," check repeat x",tgt_repeat," do? ",strlen % tgt_repeat == 0)
		if strlen % tgt_repeat == 0:
			var all_good: bool = true
			var tgt_len: int = strlen / tgt_repeat
			var first_part = string.substr(0, tgt_len)
			for i in range(tgt_repeat - 1):
				var next_part = string.substr(tgt_len * (i + 1), tgt_len)
				# print("\tcompare", next_part, " vs ", first_part)
				if next_part != first_part:
					all_good = false
			# print("Checking if ", string, " is ", first_part, " repeated x", tgt_repeat, " = ", all_good)
			if all_good:
				var multiple_node = BSTMultiple.new(first_part, [greedy_parse(first_part)])
				multiple_node.repeat_count = tgt_repeat
				min_stack_depth_cache[string] = multiple_node.depth()
				return multiple_node
	# Otherwise its an "and" thingy.
	# Try splitting it such that the depth is minimal
	var min_split_depth: int = strlen * 10
	var min_split_idx: int

	for split_pos in range(1, strlen):
		# split_pos is the length of the first part = start index of second part
		var stack_first = string.substr(0, split_pos)
		var stack_second = string.substr(split_pos)

		var depth_first: int = min_stack_depth_cache.get(stack_first, -1)
		if depth_first == -1:
			depth_first = greedy_parse(stack_first).depth()
			min_stack_depth_cache[stack_first] = depth_first

		var depth_second: int = min_stack_depth_cache.get(stack_second, -1)
		if depth_second == -1:
			depth_second = greedy_parse(stack_second).depth()
			min_stack_depth_cache[stack_second] = depth_second

		var max_depth = max(depth_first, depth_second)
		if max_depth < min_split_depth:
			min_split_depth = max_depth
			min_split_idx = split_pos

	var first = string.substr(0, min_split_idx)
	var second = string.substr(min_split_idx)

	print("Splitting ",string," as ",first," + ",second)
		
	return BSTSequence.new(string, [greedy_parse(first), greedy_parse(second)])
