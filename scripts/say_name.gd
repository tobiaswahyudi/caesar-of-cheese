extends Label

@export var prefix: String
@export var suffix: String

@export var stacker: Stacker

func _physics_process(_delta: float) -> void:
	var stack_string: String = stacker.stack_string
	var parsed_bst = Parser.greedy_parse(stack_string)
	text = prefix + parsed_bst.get_name() + suffix + "\n" + parsed_bst.get_repr()
