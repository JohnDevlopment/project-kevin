extends Resource
class_name Stats

export(int, 1, 500) var max_health: int = 5
export(int, 0, 500) var max_mana: int = 0
export(int, 1, 100) var attack: int = 1
export(int, 0, 100) var defense: int = 0

var health: int = 0
var mana: int = 0

func init_stats():
	health = max_health
	mana = max_mana

func calculate_damage(other_stats: Stats) -> int:
	var result = max(0, other_stats.attack - defense)
	return int(result)
