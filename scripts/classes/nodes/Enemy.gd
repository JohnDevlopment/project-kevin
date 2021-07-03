tool
extends Actor
class_name Enemy, "res://assets/textures/icons/Enemy.svg"

var stats
var armor_time: float = 1.0
var invincibility_timer: Timer
var direction: = Vector2.LEFT

func _enter_tree():
	if Engine.editor_hint: return
	invincibility_timer = Timer.new()
	invincibility_timer.one_shot = true
	invincibility_timer.wait_time = armor_time
	add_child(invincibility_timer)

func _get(property):
	match property:
		"armor_time":
			return armor_time
		"stats":
			return stats

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

func _ready():
	if Engine.editor_hint: return
	assert(stats, "Enemy needs a 'stats' property")
	stats.init_stats(self)
	var temp = stats.get_meta("owner")
	print(temp)

func _set(property, value):
	match property:
		"armor_time":
			armor_time = value
		"stats":
			stats = value
		_:
			return false
	return true

func decide_damage(other_stats: Stats) -> void:
	if not should_damage(): return
	var dmg = stats.calculate_damage(other_stats)
	stats.health = max(0, stats.health - dmg)
	if has_method("_on_damaged"):
		call("_on_damaged", other_stats)

func get_health() -> int:
	return stats.health

func should_damage() -> bool:
	var result: bool = invincibility_timer.is_stopped()
	if has_method("_should_damage"):
		result = result && call("_should_damage")
	return result
