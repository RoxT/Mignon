extends Resource
class_name EnemyChickens

const noms := ["Emma", "Louise", "Jade", "Alice", "Chloé", "Lina", "Mila", "Léa", "Manon", "Rose", "Anna", "Inès", "Camille", "Lola", "Ambre", "Léna", "Zoé", "Juliette", "Julia", "Lou", "Sarah", "Lucie", "Mia", "Jeanne", "Romane", "Agathe", "Eva", "Nina", "Charlotte", "Inaya", "Léonie", "Sofia", "Margaux", "Louna", "Clara", "Luna", "Maëlys", "Olivia", "Adèle", "Lilou", "Clémence", "Lana", "Léana", "Capucine", "Elena", "Victoria", "Aya", "Mathilde", "Margot", "Iris", "Anaïs", "Giulia", "Alicia", "Romy", "Nour", "Elise", "Théa", "Victoire", "Yasmine", "Lya", "Mya", "Elsa", "Charlie", "Assia", "Lise", "Lily", "Noémie", "Emy", "Lisa", "Lyna", "Marie", "Soline", "Apolline", "Alix", "Gabrielle", "Valentine", "Louane", "Candice", "Pauline", "Faustine", "Héloïse", "Océane", "Ines", "Mélina", "Maya", "Thaïs", "Roxane", "Salomé", "Lila", "Maria", "Constance", "Célia", "Sara", "Livia", "Zélie", "Lyana", "Emmy", "Alya", "Elisa", "Maryam", "Eloïse", "Myla", "Manel", "Laura", "Amélia", "Maëlle", "Justine", "Louisa", "Elina", "Maïssa","Aimeé","Belle","Bijou","Chérie","Coquette","Fleur","Lyonette","Mignon","Coco"]
const LENGTH := 119

export(int) var health
#export(Resource) var sub_resource
#export(Array, String) var strings

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(new_health = 0):
	health = new_health
	
static func get_random_nom()->String:
	var i := randi() % LENGTH
	return get_nom(i)

static func get_nom(i:int)->String:
	return noms[i]
