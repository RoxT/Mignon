extends Node2D


var leagues := {
	"BRONZE" : ["St. Germain's", "Anualonacu", "QkChkns"],
	"SILVER" : ["Bec-de-Beak", "Jam Jar Farms", "QkChkns",],
	"GOLD" : ["Vanchokons", "Martot", "Bec-de-Beak"]
}

var farms:Array
export var total :float= 10
export var my_speed := 437

# Called when the node enters the scene tree for the first time.
func _ready():
	var pool = AllChickens.generate_enemy_list()
	
	var farm_names :Array= leagues.BRONZE
	farms = AllChickens.get_some_farms(farm_names, pool)
	for chicken in $Bronze.get_children():
		do_runs(chicken)
		
	farm_names = leagues.SILVER
	farms = AllChickens.get_some_farms(farm_names, pool)
	for chicken in $Silver.get_children():
		do_runs(chicken)
		
	farm_names = leagues.GOLD
	farms = AllChickens.get_some_farms(farm_names, pool)
	for chicken in $Gold.get_children():
		do_runs(chicken)
	

func do_runs(chicken):
	var wins :float= 0
	var stats :Chicken = chicken.stats
	stats.top_speed = my_speed
	
	for _i in range(total):
		if do_run(stats):
			if do_run(stats):
				if do_run(stats):
					wins += 1
	
	var ratio:float = wins/total
	ratio = ratio * 100
	ratio = round(ratio)
	var speed := stats.get_speed()
	chicken.label(wins, ratio)
	print(str(speed) + "," + str(wins) + "," + str(ratio))

func do_run(hero:Chicken)->bool:
	var competition := []
	for f in farms:
		f = f as Farm
		competition.append(f.chickens[randi() % f.chickens.size()])
	for c in competition:
		c.boost = 1.07
		if c.get_speed() > hero.get_speed():
			return false
	return true
