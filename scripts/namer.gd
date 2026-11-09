# This is a singleton. There may only be one oracle.
# The file name is Namer but the singleton is called Parser
# ye thats my fault and i torture only myself
extends Node

var unknown_bst_string: String = "???"

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

	func get_name(_unres_func: Variant = null) -> String:
		return "YOU_SHOULDNT_SEE_THIS(" + substring + ")"

	func get_repr() -> String:
		return substring
	
	func is_ingredient() -> bool:
		return false

	func is_patty_cheese_sequence() -> bool:
		return false

	func is_patty_sequence() -> bool:
		return false

	func is_cheese_sequence() -> bool:
		return false

	func first_unresolved_child() -> BST:
		# Yeah this will traverse the whole tree multiple times, which is not so good, but the tree size is 16 so it's fine for now
		for c in children:
			var c_unresolved = c.first_unresolved_child()
			if c_unresolved != null:
				return c_unresolved
		return null

	func resolve_first(emplace_bst: BST) -> bool:
		print("resolving me {0} with {1}".format([get_repr(), emplace_bst.get_repr()]))
		for idx in len(children):
			var c = children[idx]
			if c.is_directly_unresolved():
				print("child is directly unresolved. prev children, ", children)
				children[idx] = emplace_bst
				print("child has been directly resolved. new children, ", children)
				print("me resolved {0} after {1}. Return now".format([get_repr(), emplace_bst.get_repr()]))
				return true
			var c_unresolved = c.first_unresolved_child()
			if c_unresolved != null:
				var child_resolve = c.resolve_first(emplace_bst)
				if child_resolve:
					return true
		return false

	func is_directly_unresolved() -> bool:
		# Equivalent to (self is BSTUnresolved)
		return false

	func deep_clone() -> BST:
		return null

	func deep_cloned_children() -> Array[BST]:
		var arr: Array[BST] = []
		for c in children:
			arr.append(c.deep_clone())
		return arr

class BSTUnresolved extends BST:
	func get_name(unres_func: Variant = null) -> String:
		if unres_func:
			return unres_func.call(substring)
		return Parser.unknown_bst_string

	func get_repr() -> String:
		return "?"

	func first_unresolved_child() -> BST:
		return self

	func is_directly_unresolved() -> bool:
		return true

	func deep_clone() -> BST:
		return BSTUnresolved.new(substring, deep_cloned_children())

class BSTIngredient extends BST:
	func get_name(_unres_func: Variant = null) -> String:
		var index = Type.IngredientLetter.find(substring)
		if index == -1:
			return 'Nothing'
		return Type.IngredientName[index]

	func is_ingredient() -> bool:
		return true

	func is_patty_sequence() -> bool:
		return substring == Type.IngredientLetter[Ingredient.IngredientType.Patty]

	func is_cheese_sequence() -> bool:
		return substring == Type.IngredientLetter[Ingredient.IngredientType.Cheese]

	func depth() -> int:
		return 1

	func deep_clone() -> BST:
		return BSTIngredient.new(substring, deep_cloned_children())

class BSTBurger extends BST:
	func get_name(unres_func: Variant = null) -> String:
		if children[0].is_patty_sequence():
			return children[0].get_name(unres_func).replace(Type.IngredientName[Ingredient.IngredientType.Patty],"") + "Hamburger"
		if children[0].is_patty_cheese_sequence():
			var split = children[0].get_name(unres_func).split(" ")
			var tuples = split.slice(0, len(split) - 3) # "Patty and Cheese" or "Cheese and Patty"
			return " ".join(tuples) + " Cheeseburger"
		if children[0].is_cheese_sequence():
			return children[0].get_name(unres_func) + " Sandwich"
		return children[0].get_name(unres_func) + " Burger"

	func get_repr() -> String:
		return "[" + children[0].get_repr() + "]"

	func first_unresolved_child() -> BST:
		return children[0].first_unresolved_child()

	func deep_clone() -> BST:
		return BSTBurger.new(substring, deep_cloned_children())

class BSTSequence extends BST:
	func get_name(unres_func: Variant = null) -> String:
		var contents_name = ""
		for c in children:
			if len(contents_name) > 0:
				contents_name += " and "
			contents_name += c.get_name(unres_func)
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

	func deep_clone() -> BST:
		return BSTSequence.new(substring, deep_cloned_children())

class BSTMultiple extends BST:
	func get_name(unres_func: Variant = null) -> String:
		return tuple_name + ' ' + children[0].get_name(unres_func)

	func get_repr() -> String:
		return "(" + str(repeat_count) + "x" + children[0].get_repr() + ")"

	func is_patty_cheese_sequence() -> bool:
		return children[0].is_patty_cheese_sequence()

	func is_patty_sequence() -> bool:
		return children[0].is_patty_sequence()

	func is_cheese_sequence() -> bool:
		return children[0].is_cheese_sequence()

	func deep_clone() -> BST:
		var mult = BSTMultiple.new(substring, deep_cloned_children())
		mult.repeat_count = repeat_count
		return mult

var min_stack_depth_cache: Dictionary[String, int] = {}

# Rules
func check_rule_single(string: String) -> bool:
	return len(string) <= 1

func check_rule_burger(string: String) -> bool:
	return RegEx.create_from_string("^B.*B$").search(string) != null
	
func do_rule_burger(string: String) -> String:
	return string.substr(1, len(string) - 2)

func check_rule_repeat(string: String, tgt_repeat: int) -> bool:
	var strlen = len(string)
	if strlen % tgt_repeat != 0:
		return false
	var all_good: bool = true
	@warning_ignore("integer_division")
	var tgt_len: int = strlen / tgt_repeat
	var first_part = string.substr(0, tgt_len)
	for i in range(tgt_repeat - 1):
		var next_part = string.substr(tgt_len * (i + 1), tgt_len)
		# print("\tcompare", next_part, " vs ", first_part)
		if next_part != first_part:
			all_good = false
	# print("Checking if ", string, " is ", first_part, " repeated x", tgt_repeat, " = ", all_good)
	return all_good

func do_rule_repeat(tgt_repeat: int, string: String) -> String:
	@warning_ignore("integer_division")
	var tgt_len: int = len(string) / tgt_repeat
	var first_part = string.substr(0, tgt_len)
	return first_part

func check_rule_hamburger(string: String) -> bool:
	return RegEx.create_from_string("^BP+B$").search(string) != null

func check_rule_cheese_sandwich(string: String) -> bool:
	return RegEx.create_from_string("^BC+B$").search(string) != null

func check_rule_cheeseburger(string: String) -> bool:
	return RegEx.create_from_string("^B(PC)+B$").search(string) != null || RegEx.create_from_string("^B(CP)+B$").search(string) != null

func check_rule_lettuce(string: String) -> bool:
	return RegEx.create_from_string("L").search(string) != null

func greedy_parse(string: String) -> BST:
	# First check base cases
	var strlen = len(string)
	if strlen <= 1:
		return BSTIngredient.new(string, [])
	if check_rule_burger(string):
		var insides = do_rule_burger(string)
		return BSTBurger.new(string, [greedy_parse(insides)])

	# Check repeats, start with the most first.
	for tgt_repeat in range(4, 1, -1):
		if check_rule_repeat(string, tgt_repeat):
			var first_part = do_rule_repeat(tgt_repeat, string)
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

	# print("Splitting ",string," as ",first," + ",second)
		
	return BSTSequence.new(string, [greedy_parse(first), greedy_parse(second)])

func do_one_step_ingredient(string: String) -> BST:
	return BSTIngredient.new(string, [])

# Resolves the entire stack. Use only for base cases!
# Handles hamburgers, cheeseburgers, cheese sandwiches.
# Also single ingredients.
# Assumes it's checked already!!
func do_resolve_base_burger(string: String) -> BST:
	return greedy_parse(string)

func do_one_step_burger(string: String) -> BST:
	if len(string) == 2:
		# Nothing burger; just solve it
		return greedy_parse(string)
	var insides = do_rule_burger(string)
	return BSTBurger.new(insides, [BSTUnresolved.new(insides, [])])

func do_one_step_repeat(tgt_repeat: int, string: String) -> BST:
	var repeated = do_rule_repeat(tgt_repeat, string)
	var multiple_node = BSTMultiple.new(string, [BSTUnresolved.new(repeated, [])])
	multiple_node.repeat_count = tgt_repeat
	return multiple_node

func do_one_step_split(split_pos: int, string: String) -> BST:
	# split_pos is the length of the first part = start index of second part
	var stack_first = string.substr(0, split_pos)
	var stack_second = string.substr(split_pos)
	return BSTSequence.new(string, [BSTUnresolved.new(stack_first, []), BSTUnresolved.new(stack_second, [])])
