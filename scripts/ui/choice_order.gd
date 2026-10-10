extends RefCounted

# Display order belongs to this round's UI, independently of task selection.
var _random := RandomNumberGenerator.new()
var _orders: Dictionary = {}

func _init(seed_value: int = -1) -> void:
	if seed_value < 0:
		_random.randomize()
	else:
		_random.seed = seed_value

func options_for(task: Dictionary) -> Array:
	var identifier := str(task.id)
	if not _orders.has(identifier):
		var options: Array = task.options.duplicate()
		for index in range(options.size() - 1, 0, -1):
			var other := _random.randi_range(0, index)
			var temporary: Variant = options[index]
			options[index] = options[other]
			options[other] = temporary
		_orders[identifier] = options
	return _orders[identifier].duplicate()
