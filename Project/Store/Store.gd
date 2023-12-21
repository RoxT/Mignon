extends Node2D

var save_game:AllChickens
onready var upgrade_btn:Button = $Farm/Upgrade

const BASIC_PRICE := 1
const GOOD_PRICE := 10
const BEST_PRICE := 50

const STARTER := "Starter"
const START_DESC := "Covert Balcony Pen\nA small coop in the heart of the city, great for a few chickens."
const MEDIUM := "Medium"
const MEDIUM_DESC := "Small Farm Pen\nThe perfect little backyard coop."
const LARGE := "Large"
const LARGE_DESC := "Large Farm Pen\nAn extra large coop out in the country for those that want a lot of chickens."

const CURRENT := "Best Available: "
const NEXT := "Next: "

# Called when the node enters the scene tree for the first time.
func _ready():
	save_game = M.save_game
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
		save_game.money -= M.MEDIUM_PRICE
		save_game.pen = "Medium"
		save_game.has_medium_pen = true
	elif save_game.pen == "Medium":
		save_game.money -= M.LARGE_PRICE
		save_game.pen = "Large"
		save_game.has_large_pen = true
	_on_ToCoop_pressed()
	
func refresh_UI():
	$UI/Money.text = "Money: $" + str(save_game.money)
	$UI/Food/Panel/FoodBox/BEST.count = save_game.foods[save_game.FOOD_TYPES.BEST]
	$UI/Food/Panel/FoodBox/GOOD.count = save_game.foods[save_game.FOOD_TYPES.GOOD]
	$UI/Food/Panel/FoodBox/BASIC.count = save_game.foods[save_game.FOOD_TYPES.BASIC]
	
	$UI/Food/Panel/FoodBox/Label.visible = save_game.foods == [0,0,0]
	$BuyBasic.text = "Buy $" + str(BASIC_PRICE*multiplier())
	$BuyGood.text = "Buy $" + str(GOOD_PRICE*multiplier())
	$BuyBest.text = "Buy $" + str(BEST_PRICE*multiplier())
	
	var current:Label = $Farm/Current
	var next:Label = $Farm/Next
	
	if save_game.has_large_pen:
		current.text = CURRENT + LARGE_DESC
		next.text = ""
		upgrade_btn.disabled = true
		upgrade_btn.text = "Farm Completely Upgraded"
	elif save_game.has_medium_pen:
		current.text = CURRENT + MEDIUM_DESC
		next.text = NEXT + LARGE_DESC
		upgrade_btn.text = "Upgrade Farm $" + str(M.LARGE_PRICE)
#			upgrade_btn.disabled = save_game.money < LARGE_PRICE*multiplier()
	else:
		current.text = CURRENT + START_DESC
		next.text = NEXT + MEDIUM_DESC
		upgrade_btn.text = "Upgrade Farm $" + str(M.MEDIUM_PRICE)
#			upgrade_btn.disabled = save_game.money < MEDIUM_PRICE*multiplier()
	


func _on_ToCoop_pressed():
	save_game.save()
	var err := get_tree().change_scene("res://Coop.tscn")
	if err != OK:
		push_error("Error switching scenes: " + str(err))


func _on_More_pressed():
	save_game.save()
	var err := get_tree().change_scene("res://Store/StorePage2.tscn")
	if err != OK:
		push_error("Error switching scenes to page 2: " + str(err))
