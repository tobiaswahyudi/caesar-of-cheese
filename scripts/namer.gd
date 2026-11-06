# This is a singleton. There may only be one oracle.
extends Node

class BST:
	var substring: String
	var children: Array[BST]
	var depth: int:
		get():
			if len(children) == 0:
				return 1
			var max_child_depth: int = 0
			for c in children:
				max_child_depth = max(max_child_depth, c.depth)
			return max_child_depth + 1

	func _init(p_str: String, p_children: Array[BST]) -> void:
		substring = p_str
		children = p_children

	func get_name() -> String:
		return "YOU_SHOULDNT_SEE_THIS(" + substring + ")"

	func get_repr() -> String:
		return substring

class BSTIngredient extends BST:
	func get_name() -> String:
		var index = Type.IngredientLetter.find(substring)
		if index == -1:
			return 'Nothing'
		return Type.IngredientName[index]

class BSTBurger extends BST:
	func get_name() -> String:
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

class BSTMultiple extends BST:
	var tuple_names = [
		'',
		'',
		'Double',
		'Triple',
		'Quadruple',
	]
	var repeat_count: int
	func get_name() -> String:
		var tuple_name = str(repeat_count) + 'x' if repeat_count > 4 else tuple_names[repeat_count]
		return tuple_name + ' ' + children[0].get_name()

	func get_repr() -> String:
		return "(" + str(repeat_count) + "x" + children[0].get_repr() + ")"

var MIN_STACK_DEPTH_CACHE: Dictionary[String, int] = {}

func greedy_parse(string: String) -> BST:
	# First check base cases
	var strlen = len(string)
	if strlen <= 1:
		return BSTIngredient.new(string, [])
	if RegEx.create_from_string("^B.*B$").search(string):
		var insides = string.substr(1, strlen - 2)
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
				MIN_STACK_DEPTH_CACHE[string] = multiple_node.depth
				return multiple_node
	# Otherwise its an "and" thingy.
	# Try splitting it such that the depth is minimal

	var stack_top = string[-1]
	var stack_rest = string.substr(0, strlen - 1)
	return BSTSequence.new(string, [greedy_parse(stack_rest), greedy_parse(stack_top)])
