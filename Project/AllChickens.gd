extends Resource
class_name AllChickens
export(Array, Resource) var all:Array setget , get_all
export(Array, Resource) var enemy_farms:Array setget , get_enemy_farms
export(Resource) var racer setget set_racer
export(Resource) var temp_racer setget set_temp_racer
export(int) var money
export(int) var deaths
export(String) var pen
export(Array) var foods
export(bool) var speed_boost
export(bool) var show_diary
export(bool) var has_hybrid
export(int) var day
export(int) var wins
export(int) var losses
export(Dictionary) var breeds_discovered
export(Resource) var last_racer
export(int) var next_unique_no
export(Array) var events
export(bool) var new_alert
export(String, "BRONZE", "SILVER", "GOLD", "END") var current_league
export(Dictionary) var leagues_ongoing
export(Dictionary) var last_zoo_report
export(bool) var has_mature
export(bool) var has_elderly
export(Resource) var last_sold_chicken
export(bool) var has_medium_pen
export(bool) var has_large_pen
export(bool)var has_beat_vanchockens

enum FOOD_TYPES {BEST, GOOD, BASIC}

const PATH := "user://chickens.tres"
const PATH_BACKUP := "user://chickens_backup.tres"
const YOU := "YOU"

signal alert

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(new_all = [], new_racer=null, new_money := 100, new_deaths := 0, new_temp_racer = null, new_pen="Starter", new_enemy_farms = [], new_foods = [0,10,0], new_speed_boost:=1.0, new_show_diary:=true, new_day=1, new_wins=0, new_losses=0, new_breeds_discovered = {}, new_last_racer=null, new_next_unique_no := 0, new_events:=[], new_new_alert:=false, new_has_hybrid = false, new_current_league = "BRONZE", new_last_zoo_report = {}, new_leagues_ongoing = {}, new_has_mature=false, new_has_elderly=false, new_last_sold_chicken=null, new_has_medium_pen=false, new_has_large_pen=false, new_has_beat_vanchockens=false):
	all = new_all
	racer = new_racer
	money = new_money
	deaths = new_deaths
	temp_racer = new_temp_racer
	pen = new_pen
	enemy_farms = new_enemy_farms
	foods = new_foods
	speed_boost = new_speed_boost
	day = new_day
	wins = new_wins
	losses = new_losses
	breeds_discovered = new_breeds_discovered
	last_racer = new_last_racer
	next_unique_no = new_next_unique_no
	events = new_events
	has_hybrid = new_has_hybrid
	current_league = new_current_league
	last_zoo_report = new_last_zoo_report
	leagues_ongoing = new_leagues_ongoing
	new_alert = new_new_alert
	show_diary = new_show_diary
	has_mature = new_has_mature
	has_elderly = new_has_elderly
	last_sold_chicken = new_last_sold_chicken
	has_medium_pen = new_has_medium_pen
	has_large_pen = new_has_large_pen
	has_beat_vanchockens = new_has_beat_vanchockens

func initialize_game():
	all = generate_mignon()
	enemy_farms = generate_enemy_list()
	breeds_discovered = generate_new_discovered()
	leagues_ongoing = create_leagues_ongoing()
	save_backup()

func pass_day():
	day += 1
	speed_boost = 1
	var recovery := 0
	for i in range(foods.size()):
		if foods[i] > 0:
			foods[i] -= 1
			match i:
				0: 
					recovery = 2
					speed_boost = 1.15
				1: 
					recovery = 1
					speed_boost = 1.15
				2: 
					recovery = 1
			break
	for c in all:
		c.fatigue = max(c.fatigue-recovery, 0)
		c.age += 1
		if !has_mature and c.age == c.MATURE:
			new_alert_event(Event.new(day, "MATURE", [c.nom]))
			has_mature = true
		if c.age == c.ELDERLY:
			if c.fame > 0:
				new_alert_event(Event.new(day, "FAMOUS_ELDERLY", [c.nom]))
			if !has_elderly:
				new_alert_event(Event.new(day, "ELDERLY", [c.nom]))
				has_elderly = true

	last_sold_chicken = null
	save()


static func exists()->bool:
	return ResourceLoader.exists(PATH)
	
static func backup_exists()->bool:
	return ResourceLoader.exists(PATH_BACKUP)

func get_all()->Array:
	return all
	
func get_enemy_farms()->Array:
	return enemy_farms
	
static func get_some_farms(farm_names:Array, pool:Array)->Array:
	var a := []
	for farm in pool:
		if farm_names.find(farm.nom) >= 0:
			a.append(farm)
	assert(a.size() == farm_names.size())
	return a
	
func do_mating(a:Chicken, b:Chicken)->Chicken:
	var bonus := rand_range(-2,5)
	var breed
	var nom = Chicken.random_name()
	for key in M.pairs.keys():
		if key == a.breed:
			for subkey in M.pairs[key].keys():
				if subkey == b.breed:
					breed = M.pairs[key][subkey]
					breeds_discovered[breed] = true
					bonus += 3
					if not has_hybrid:
						has_hybrid = true
						new_alert = true
						new_alert_event(Event.new(day, "HYBRID", 
							[a.nom, b.nom, nom, breed.capitalize()]))
	if not breed: breed = one_of_two(a, b, "breed")
	
	var lineage := [a.unique_no, b.unique_no]
	lineage.append_array(a.parents_grandparents.slice(0,1))
	lineage.append_array(b.parents_grandparents.slice(0,1))
	
	return Chicken.new(
		round(one_of_two(a, b, "top_speed")+bonus), 
		nom, 
		0, 
		one_of_two(a, b, "colour"), 
		one_of_two(a, b, "farm"), 
		0, 
		breed,
		lineage,
		get_new_unique_no())

func new_alert_event(event:Event):
	new_alert = true
	emit_signal("alert")
	events.append(event)

func find_event(event:String)->int:
	for i in range(events.size()):
		if event == events[i].key:
			return i
	return -1

static func one_of_two(a:Chicken, b:Chicken, property:String):
	return [a.get(property), b.get(property)][randi()%2]

func save():
	var err := ResourceSaver.save(PATH, self)
	if err != OK: push_error("Error saving! " + str(err))
	assert(err == OK)
	
func save_backup():
	var err := ResourceSaver.save(PATH_BACKUP, self)
	if err != OK: push_error("Error saving backup! " + str(err))
	assert(err == OK)
	
func sell(chicken:Chicken, price:int):
	if racer == chicken:
		racer = null
	last_sold_chicken = chicken.duplicate()
	all.erase(chicken)
	money += price
	save()

func buy_back_last():
	var come_back:Chicken = last_sold_chicken.duplicate()
	all.append(come_back)
	last_racer = come_back
	money -= come_back.get_price()
	last_sold_chicken = null
	save()

func add_chicken_stats(value:Chicken):
	assert(value != null)
	if value.unique_no < 0:
		value.unique_no = get_new_unique_no()
	all.append(value)
	save()

func set_racer(value:Resource):
	racer = value as Chicken
	save()

func set_temp_racer(value:Resource):
	if value:
		temp_racer = value as Chicken
	else: temp_racer = value
	save()

func get_new_unique_no()->int:
	next_unique_no += 1
	return next_unique_no
	
func create_zoo_report(adults:int, children:int, modifiers:Array, breeds:Array, regulars:int, fans:int):
	var report := {}
	report["day"] = day
	report["adults"] = adults
	report["children"] = children
	report["modifiers"] = modifiers
	report["breeds"] = breeds
	report["regulars"] = regulars
	report["fans"] = fans
	last_zoo_report = report
	
func already_zooed()->bool:
	return last_zoo_report and last_zoo_report.day == day

func add_to_leagues_ongoing(loser:Chicken, winner:Chicken):
	if current_league == "END": return
	var bracket = leagues_ongoing[current_league]
	if bracket.has(loser.farm):
		var i = bracket[loser.farm].winners.size()
		if i < 3:
			bracket[loser.farm].winners.append(winner)
			bracket[loser.farm].losers.append(loser)
			if i == 2:
				if was_league_won(current_league):
					winner.fame += 1
					new_alert_event(Event.new(current_league))
					match current_league:
						M.BRONZE: current_league = M.SILVER
						M.SILVER: current_league = M.GOLD
						M.GOLD: current_league = "END"
	
func create_leagues_ongoing()->Dictionary:
	var leagues = {}
	for key in M.leagues.keys():
		var bracket := {}
		for farm in M.leagues[key].farms:
			bracket[farm] = {"winners": [], "losers": []}
		leagues[key] = bracket
	return leagues

func was_league_won(league:String)->bool:
	for farm in leagues_ongoing[league]:
		if leagues_ongoing[league][farm].winners.size() < 3:
			return false
	return true

func death(value:Chicken):
	if racer == value:
		racer = null
	all.erase(value)
	deaths += 1
	save()
	
func get_competition(lanes:int)->Array:
	if lanes > enemy_farms.size(): push_error("More lanes than Farms")
	var competition := []
	var farms = choose_farms(lanes, bag(enemy_farms.size()), enemy_farms)
	for f in farms:
		f = f as Farm
		competition.append(f.get_random())
	return competition

static func choose_farms(lanes, bag_of_indexes, enemies)->Array:
	var farms := []
	while farms.size() < lanes:
		var i:int = bag_of_indexes[randi() % bag_of_indexes.size()]
		farms.append(enemies[i])
		bag_of_indexes.erase(i)
	return farms

static func bag(things:int)->Array:
	var bag := []
	for i in range(things):
		bag.append(i)
	return bag
	
func buy_food(type:int, amount:int, cost:=0):
	foods[type] += amount
	money -= cost
	save()
	
func generate_mignon()->Array:
	var new_coop := []
	var mignon := Chicken.new()
	mignon.top_speed = 280
	mignon.colour = Color.white
	mignon.breed = M.PLYMOUTH_ROCK
	mignon.farm = YOU
	mignon.nom = "Mignon"
	mignon.unique_no = get_new_unique_no()
	new_coop.append(mignon)
	
	var one := Chicken.new()
	one.top_speed = 240
	one.farm = YOU
	one.unique_no = get_new_unique_no()
	new_coop.append(one)
	
	var two := Chicken.new()
	two.top_speed = 250
	two.farm = YOU
	two.unique_no = get_new_unique_no()
	new_coop.append(two)
	
	return new_coop
	
func generate_new_discovered()->Dictionary:
	var new_discovered := {}
	for b in M.BREEDS_LIST:
		new_discovered[b] = false
	for d in M.DEFUALT_BREEDS:
		new_discovered[d] = true
	return new_discovered
	
static func generate_enemy_list()->Array:
	var e := []
	var file := File.new()
	var err = file.open("res://Common/JSON/enemy_chickens.json", File.READ)
	if err != OK: push_error("Error opening enemy_chickens.json" + str(err))
	var content = file.get_as_text()
	var list_of_farms:Dictionary = JSON.parse(content).result
	for f_key in list_of_farms.keys():
		var farm := Farm.new()
		farm.nom = f_key
		for c_key in list_of_farms[f_key].chickens.keys():
			var chicken := Chicken.new()
			chicken.breed = M.BREEDS_LIST[randi() % M.BREEDS_LIST.size()]
			chicken.nom = c_key
			var this_chicken:Dictionary = list_of_farms[f_key].chickens[c_key]
			for k in this_chicken.keys():
				chicken.set(k,this_chicken[k])
			chicken.farm = f_key
			farm.chickens.append(chicken)
		e.append(farm)
	
	file.close()
	return e
