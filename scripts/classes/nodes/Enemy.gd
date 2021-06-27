tool
extends Actor
class_name Enemy, "res://assets/textures/icons/Enemy.svg"

var stats
var armor_time: float = 1.0
var timer: Timer

func _get(property):
	match property:
		"armor_time":
			return armor_time
		"stats":
			return stats

func _set(property, value):
	match property:
		"armor_time":
			armor_time = value
		"stats":
			stats = value
		_:
			return false
	return true

func _get_property_list():
	return [
		{
			name = "Enemy",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "armor_time",
			type = TYPE_REAL,
			usage = PROPERTY_USAGE_DEFAULT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0.1,10,0.1,or_greater"
		},
		{
			name = "stats",
			type = TYPE_OBJECT,
			usage = PROPERTY_USAGE_DEFAULT,
			hint = PROPERTY_HINT_RESOURCE_TYPE,
			hint_string = "Resource"
		}
	]

func _enter_tree():
	if Engine.editor_hint: return
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = armor_time
	add_child(timer)

func _ready():
	if Engine.editor_hint: return
	stats.init_stats()

# warning-ignore:shadowed_variable
func do_damage(other_stats: Stats) -> void:
	assert(stats is Stats, "\"stats\" is not an instance of Stats")
	var dmg = stats.calculate_damage(other_stats)
	stats.health = max(0, stats.health - dmg)
	if has_method("_do_damage"):
		call("_do_damage", other_stats)

func get_health() -> int:
	return stats.health
