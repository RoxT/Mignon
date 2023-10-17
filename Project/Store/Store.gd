extends Node2D

var save_game:AllChickens
const BASIC_PRICE := 1
const GOOD_PRICE := 5
const BEST_PRICE := 10

const STARTER := "Starter"
const MEDIUM := "Medium"
const LARGE := "Large"

const MEDIUM_PRICE := 200
const LARGE_PRICE := 400

const CURRENT := "Current: "
const NEXT := "Next: "

# Called when the node enters the scene tree for the first time.
func _ready():
	if AllChickens.exists():
		save_game = load(AllChickens.PATH) as AllChickens
	else:
		save_game = AllChickens.new()
		save_game.save()
		print("New Game")
	save_game.save()
	refresh_UI()

func multiplier()->int:
	match save_game.pen:
		"Starter":
			return 1
		"Medium": 
			return 2
		"Large":
			return 3
	return -1

func _on_BuyBasic_pressed():
	save_game.buy_food(save_game.FOOD_TYPES.BASIC, 1, BASIC_PRICE*multiplier())
	refresh_UI()

func _on_BuyGood_pressed():
	save_game.buy_food(save_game.FOOD_TYPES.GOOD, 1, GOOD_PRICE*multiplier())
	refresh_UI()

func _on_BuyBest_pressed():
	save_game.buy_food(save_game.FOOD_TYPES.BEST, 1, BEST_PRICE*multiplier())
	refresh_UI()

func _on_Upgrade_pressed():
	if save_game.pen == "Starter":
		save_game.money -= MEDIUM_PRICE 
		save_game.pen = "Medium"
	elif save_game.pen == "Medium":
		save_game.money -= LARGE_PRICE
		save_game.pen = "Large"
	save_game.save()
	refresh_UI()
	
func refresh_UI():
	$UI/Money.text = "Money: $" + str(save_game.money)
	$UI/Food/Panel/FoodBox/BEST.count = save_game.foods[save_game.FOOD_TYPES.BEST]
	$UI/Food/Panel/FoodBox/GOOD.count = save_game.foods[save_game.FOOD_TYPES.GOOD]
	$UI/Food/Panel/FoodBox/BASIC.count = save_game.foods[save_game.FOOD_TYPES.BASIC]
	
	$BuyBasic.text = "Buy $" + str(BASIC_PRICE*multiplier())
	$BuyGood.text = "Buy $" + str(GOOD_PRICE*multiplier())
	$BuyBest.text = "Buy $" + str(BEST_PRICE*multiplier())
	
	var current:Label = $Current
	var next:Label = $Next
	match save_game.pen:
		"Starter":
			current.text = CURRENT + "Covert Balcony Pen"
			next.text = NEXT + "Small Farm Pen"
		"Medium":
			current.text = CURRENT + "Small Farm Pen"
			next.text = NEXT + "Large Farm Pen"
		"Large":
			current.text = CURRENT + "Large Farm Pen"
			next.text = ""
	
	var upgrade:Button = $Upgrade
	match save_game.pen:
		"Starter":
			upgrade.text = "Upgrade Farm $" + str(MEDIUM_PRICE*multiplier())
			upgrade.disabled = save_game.money < MEDIUM_PRICE*multiplier()
		"Medium":
			upgrade.text = "Upgrade Farm $" + str(LARGE_PRICE*multiplier())
			upgrade.disabled = save_game.money < LARGE_PRICE*multiplier()
		"Large":
			upgrade.disabled = true
			upgrade.text = "Farm Completely Upgraded"
		var pen:
			push_error(pen + "not a pen")

func _on_ToCoop_pressed():
	save_game.save()
	var err := get_tree().change_scene("res://Coop.tscn")
	if err != OK:
		push_error("Error switching scenes: " + str(err))
