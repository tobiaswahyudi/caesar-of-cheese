extends Node

func choose(arr: Array[Variant]) -> Variant:
	return arr[floor(randf() * len(arr))]

var ingredients: Array[Ingredient.IngredientType] = [
	Ingredient.IngredientType.Bun,
	Ingredient.IngredientType.Lettuce,
	Ingredient.IngredientType.Patty,
	Ingredient.IngredientType.Cheese,
]

var multipliers: Array[String] = ['Double','Triple','Quadruple'];

var bases: Array[Parser.BST] = [
	Parser.greedy_parse("BPB"),
	Parser.greedy_parse("BPCB"),
	Parser.greedy_parse("BCB"),
	Parser.greedy_parse("BB")
]

func generate_structurally(p_len: int) -> Array[String]:
	var action = '';

	if p_len <= 0:
		print('p_len {0}! how?'.format([p_len]))
		return []

	if p_len == 1:
		return [
			Type.IngredientName[choose(ingredients)]
		];

	if p_len == 2:
		if randf() < 0.3:
			action = "multiplier";
		else:
			return [choose(bases).deep_clone().get_name()]

	if p_len >= 3:
		var rand = randf();
		if rand < 0.35:
			action = "cut";
		elif rand < 0.65:
			action = "multiplier";
		else:
			action = "burger";

	print(' '.repeat(p_len) + ' p_len ' + str(p_len) + ' action ' + action)
	if action == "multiplier":
		var c_mult: Array[String] = [choose(multipliers)]
		var gen_rest: Array[String] = generate_structurally(p_len - 1)
		print("mult + " + str(c_mult) + " " + str(gen_rest))
		return c_mult + gen_rest
	if action == "burger":
		var gen_rest: Array[String] = generate_structurally(p_len - 1)
		var burger: Array[String] = ["Burger"]
		return gen_rest + burger
	if action == "cut":
		var leftCount = int(floor(randf() * (p_len - 3)) + 1);
		var rightCount = int(p_len - 1 - leftCount);

		var gen_left: Array[String] = generate_structurally(leftCount)
		var gen_right: Array[String] = generate_structurally(rightCount)
		var l_and: Array[String] = ['and']

		return gen_left + l_and + gen_right;
	return []
	

func solve_name(arr: Array[String]) -> String:
	return ' '.join(arr)

func make_satisfactory_name(name_complexity: int, prev_name: String) -> String:
	var random_name: String
	while true:
		var random_name_parts = generate_structurally(name_complexity)
		random_name = solve_name(random_name_parts)
		if random_name == prev_name:
			continue
		# Let's just disallow "Patty Burger" since it may result in unsolveables
		if RegEx.create_from_string("Patty Burger").search(random_name) != null:
			continue
		# Check number of multipliers. We cannot have too many.
		var multiplier_count = 0
		for part in random_name_parts:
			for mult in multipliers:
				if part == mult:
					multiplier_count += 1

		if multiplier_count > 3:
			continue
		break

	# Make sure it's a burger and never a split-and
	if not random_name.ends_with(" Burger"):
		random_name += ' Burger'

	return random_name
