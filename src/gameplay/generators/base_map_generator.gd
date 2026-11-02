class_name BaseMapGenerator
extends MapGenerator
## Port of Gameplay/Generators/BaseMapGenerator.cs
## Abstract generator base with actor dressing/naming/skills helpers, common
## map object and item factories, wall decoration, barricading and zones.
##
## Adaptations:
## - C# overloads flattened with "_with" suffixes for the full-argument forms.
## - C# object-initializer syntax expanded into property assignments.
## - GameItems model constants (C# properties like GameItems.BANDAGE) are
##   accessor methods on the ported GameItems DB (game.game_items.bandage()).

var game: RogueGame


func _init(p_game: RogueGame) -> void:
	super(p_game.rules)
	game = p_game


# Actor dressing helpers

const MALE_SKINS: Array = [GameImages.MALE_SKIN1, GameImages.MALE_SKIN2, GameImages.MALE_SKIN3, GameImages.MALE_SKIN4, GameImages.MALE_SKIN5]
const MALE_HEADS: Array = [GameImages.MALE_HAIR1, GameImages.MALE_HAIR2, GameImages.MALE_HAIR3, GameImages.MALE_HAIR4, GameImages.MALE_HAIR5, GameImages.MALE_HAIR6, GameImages.MALE_HAIR7, GameImages.MALE_HAIR8]
const MALE_TORSOS: Array = [GameImages.MALE_SHIRT1, GameImages.MALE_SHIRT2, GameImages.MALE_SHIRT3, GameImages.MALE_SHIRT4, GameImages.MALE_SHIRT5]
const MALE_LEGS: Array = [GameImages.MALE_PANTS1, GameImages.MALE_PANTS2, GameImages.MALE_PANTS3, GameImages.MALE_PANTS4, GameImages.MALE_PANTS5]
const MALE_SHOES: Array = [GameImages.MALE_SHOES1, GameImages.MALE_SHOES2, GameImages.MALE_SHOES3]
const MALE_EYES: Array = [GameImages.MALE_EYES1, GameImages.MALE_EYES2, GameImages.MALE_EYES3, GameImages.MALE_EYES4, GameImages.MALE_EYES5, GameImages.MALE_EYES6]

const FEMALE_SKINS: Array = [GameImages.FEMALE_SKIN1, GameImages.FEMALE_SKIN2, GameImages.FEMALE_SKIN3, GameImages.FEMALE_SKIN4, GameImages.FEMALE_SKIN5]
const FEMALE_HEADS: Array = [GameImages.FEMALE_HAIR1, GameImages.FEMALE_HAIR2, GameImages.FEMALE_HAIR3, GameImages.FEMALE_HAIR4, GameImages.FEMALE_HAIR5, GameImages.FEMALE_HAIR6, GameImages.FEMALE_HAIR7]
const FEMALE_TORSOS: Array = [GameImages.FEMALE_SHIRT1, GameImages.FEMALE_SHIRT2, GameImages.FEMALE_SHIRT3, GameImages.FEMALE_SHIRT4]
const FEMALE_LEGS: Array = [GameImages.FEMALE_PANTS1, GameImages.FEMALE_PANTS2, GameImages.FEMALE_PANTS3, GameImages.FEMALE_PANTS4, GameImages.FEMALE_PANTS5]
const FEMALE_SHOES: Array = [GameImages.FEMALE_SHOES1, GameImages.FEMALE_SHOES2, GameImages.FEMALE_SHOES3]
const FEMALE_EYES: Array = [GameImages.FEMALE_EYES1, GameImages.FEMALE_EYES2, GameImages.FEMALE_EYES3, GameImages.FEMALE_EYES4, GameImages.FEMALE_EYES5, GameImages.FEMALE_EYES6]

const BIKER_HEADS: Array = [GameImages.BIKER_HAIR1, GameImages.BIKER_HAIR2, GameImages.BIKER_HAIR3]
const BIKER_LEGS: Array = [GameImages.BIKER_PANTS]
const BIKER_SHOES: Array = [GameImages.BIKER_SHOES]

const CHARGUARD_HEADS: Array = [GameImages.CHARGUARD_HAIR]
const CHARGUARD_LEGS: Array = [GameImages.CHARGUARD_PANTS]

const DOG_SKINS: Array = [GameImages.DOG_SKIN1, GameImages.DOG_SKIN2, GameImages.DOG_SKIN3]


func dress_civilian(roller: DiceRoller, actor: Actor) -> void:
	if actor.model.doll_body.is_male:
		dress_civilian_with(roller, actor, MALE_EYES, MALE_SKINS, MALE_HEADS, MALE_TORSOS, MALE_LEGS, MALE_SHOES)
	else:
		dress_civilian_with(roller, actor, FEMALE_EYES, FEMALE_SKINS, FEMALE_HEADS, FEMALE_TORSOS, FEMALE_LEGS, FEMALE_SHOES)


func skin_naked_human(roller: DiceRoller, actor: Actor) -> void:
	if actor.model.doll_body.is_male:
		skin_naked_human_with(roller, actor, MALE_EYES, MALE_SKINS, MALE_HEADS)
	else:
		skin_naked_human_with(roller, actor, FEMALE_EYES, FEMALE_SKINS, FEMALE_HEADS)


func dress_civilian_with(roller: DiceRoller, actor: Actor, eyes: Array, skins: Array, heads: Array, torsos: Array, legs: Array, shoes: Array) -> void:
	actor.doll.remove_all_decorations()
	actor.doll.add_decoration(Doll.DollPart.EYES, eyes[roller.roll(0, eyes.size())])
	actor.doll.add_decoration(Doll.DollPart.SKIN, skins[roller.roll(0, skins.size())])
	actor.doll.add_decoration(Doll.DollPart.HEAD, heads[roller.roll(0, heads.size())])
	actor.doll.add_decoration(Doll.DollPart.TORSO, torsos[roller.roll(0, torsos.size())])
	actor.doll.add_decoration(Doll.DollPart.LEGS, legs[roller.roll(0, legs.size())])
	actor.doll.add_decoration(Doll.DollPart.FEET, shoes[roller.roll(0, shoes.size())])


func skin_naked_human_with(roller: DiceRoller, actor: Actor, eyes: Array, skins: Array, heads: Array) -> void:
	actor.doll.remove_all_decorations()
	actor.doll.add_decoration(Doll.DollPart.EYES, eyes[roller.roll(0, eyes.size())])
	actor.doll.add_decoration(Doll.DollPart.SKIN, skins[roller.roll(0, skins.size())])
	actor.doll.add_decoration(Doll.DollPart.HEAD, heads[roller.roll(0, heads.size())])


func skin_dog(roller: DiceRoller, actor: Actor) -> void:
	actor.doll.remove_all_decorations()
	actor.doll.add_decoration(Doll.DollPart.SKIN, DOG_SKINS[roller.roll(0, DOG_SKINS.size())])


func dress_army(roller: DiceRoller, actor: Actor) -> void:
	actor.doll.remove_all_decorations()
	actor.doll.add_decoration(Doll.DollPart.SKIN, MALE_SKINS[roller.roll(0, MALE_SKINS.size())])
	actor.doll.add_decoration(Doll.DollPart.HEAD, GameImages.ARMY_HELMET)
	actor.doll.add_decoration(Doll.DollPart.TORSO, GameImages.ARMY_SHIRT)
	actor.doll.add_decoration(Doll.DollPart.LEGS, GameImages.ARMY_PANTS)
	actor.doll.add_decoration(Doll.DollPart.FEET, GameImages.ARMY_SHOES)


func dress_police(roller: DiceRoller, actor: Actor) -> void:
	actor.doll.remove_all_decorations()
	actor.doll.add_decoration(Doll.DollPart.EYES, MALE_EYES[roller.roll(0, MALE_EYES.size())])
	actor.doll.add_decoration(Doll.DollPart.SKIN, MALE_SKINS[roller.roll(0, MALE_SKINS.size())])
	actor.doll.add_decoration(Doll.DollPart.HEAD, MALE_HEADS[roller.roll(0, MALE_HEADS.size())])
	actor.doll.add_decoration(Doll.DollPart.HEAD, GameImages.POLICE_HAT)
	actor.doll.add_decoration(Doll.DollPart.TORSO, GameImages.POLICE_UNIFORM)
	actor.doll.add_decoration(Doll.DollPart.LEGS, GameImages.POLICE_PANTS)
	actor.doll.add_decoration(Doll.DollPart.FEET, GameImages.POLICE_SHOES)


func dress_biker(roller: DiceRoller, actor: Actor) -> void:
	actor.doll.remove_all_decorations()
	actor.doll.add_decoration(Doll.DollPart.EYES, MALE_EYES[roller.roll(0, MALE_EYES.size())])
	actor.doll.add_decoration(Doll.DollPart.SKIN, MALE_SKINS[roller.roll(0, MALE_SKINS.size())])
	actor.doll.add_decoration(Doll.DollPart.HEAD, BIKER_HEADS[roller.roll(0, BIKER_HEADS.size())])
	actor.doll.add_decoration(Doll.DollPart.LEGS, BIKER_LEGS[roller.roll(0, BIKER_LEGS.size())])
	actor.doll.add_decoration(Doll.DollPart.FEET, BIKER_SHOES[roller.roll(0, BIKER_SHOES.size())])


func dress_gangsta(roller: DiceRoller, actor: Actor) -> void:
	actor.doll.remove_all_decorations()
	actor.doll.add_decoration(Doll.DollPart.EYES, MALE_EYES[roller.roll(0, MALE_EYES.size())])
	actor.doll.add_decoration(Doll.DollPart.SKIN, MALE_SKINS[roller.roll(0, MALE_SKINS.size())])
	actor.doll.add_decoration(Doll.DollPart.TORSO, GameImages.GANGSTA_SHIRT)
	actor.doll.add_decoration(Doll.DollPart.HEAD, MALE_HEADS[roller.roll(0, MALE_HEADS.size())])
	actor.doll.add_decoration(Doll.DollPart.HEAD, GameImages.GANGSTA_HAT)
	actor.doll.add_decoration(Doll.DollPart.LEGS, GameImages.GANGSTA_PANTS)
	actor.doll.add_decoration(Doll.DollPart.FEET, MALE_SHOES[roller.roll(0, MALE_SHOES.size())])


func dress_char_guard(roller: DiceRoller, actor: Actor) -> void:
	actor.doll.remove_all_decorations()
	actor.doll.add_decoration(Doll.DollPart.EYES, MALE_EYES[roller.roll(0, MALE_EYES.size())])
	actor.doll.add_decoration(Doll.DollPart.SKIN, MALE_SKINS[roller.roll(0, MALE_SKINS.size())])
	actor.doll.add_decoration(Doll.DollPart.HEAD, CHARGUARD_HEADS[roller.roll(0, CHARGUARD_HEADS.size())])
	actor.doll.add_decoration(Doll.DollPart.LEGS, CHARGUARD_LEGS[roller.roll(0, CHARGUARD_LEGS.size())])


func dress_black_ops(roller: DiceRoller, actor: Actor) -> void:
	actor.doll.remove_all_decorations()
	actor.doll.add_decoration(Doll.DollPart.EYES, MALE_EYES[roller.roll(0, MALE_EYES.size())])
	actor.doll.add_decoration(Doll.DollPart.SKIN, MALE_SKINS[roller.roll(0, MALE_SKINS.size())])
	actor.doll.add_decoration(Doll.DollPart.TORSO, GameImages.BLACKOP_SUIT)


func random_skin(roller: DiceRoller, is_male: bool) -> String:
	var skins: Array = MALE_SKINS if is_male else FEMALE_SKINS
	return skins[roller.roll(0, skins.size())]


# Actor naming helpers

# alpha10.1 added new male first names
const MALE_FIRST_NAMES: Array = [
	"Aaron", "Adam", "Adrian", "Alan", "Albert", "Alberto", "Alex", "Alexander", "Alfred", "Alfredo", "Allan", "Allen", "Alvin", "Andre", "Andrew", "Andy", "Angel", "Anton", "Antonio", "Anthony", "Armando", "Arnold", "Arthur", "Ashley", "Axel",
	"Barry", "Ben", "Benjamin", "Bernard", "Bill", "Billy", "Bob", "Bobby", "Brad", "Brandon", "Bradley", "Brent", "Brett", "Brian", "Bryan", "Bruce", "Byron",
	"Caine", "Calvin", "Carl", "Carlos", "Carlton", "Casey", "Cecil", "Chad", "Charles", "Charlie", "Chester", "Chris", "Christian", "Christopher", "Clarence", "Clark", "Claude", "Clayton", "Clifford", "Clifton", "Clinton", "Clyde", "Cody", "Corey", "Cory", "Craig", "Cris", "Cristobal", "Curtis",
	"Dan", "Daniel", "Danny", "Dale", "Darrell", "Darren", "Darryl", "Dave", "David", "Dean", "Dennis", "Derek", "Derrick", "Dirk", "Don", "Donald", "Donovan", "Doug", "Douglas", "Duane", "Dustin", "Dwayne", "Dwight",
	"Earl", "Ed", "Eddie", "Eddy", "Edgar", "Eduardo", "Edward", "Edwin", "Elias", "Elie", "Elmer", "Elton", "Enrique", "Eric", "Erik", "Ernest", "Eugene", "Everett",
	"Felix", "Fernando", "Floyd", "Francis", "Francisco", "Frank", "Franklin", "Fred", "Frederick", "Freddie",
	"Gabriel", "Gary", "Gene", "George", "Georges", "Gerald", "Gilbert", "Glenn", "Gordon", "Greg", "Gregory", "Guy",
	"Hank", "Harold", "Harvey", "Harry", "Hector", "Henry", "Herbert", "Herman", "Howard", "Hubert", "Hugh", "Hughie",
	"Ian", "Indy", "Isaac", "Ivan",
	"Jack", "Jacob", "Jaime", "Jake", "James", "Jamie", "Jared", "Jarvis", "Jason", "Javier", "Jay", "Jeff", "Jeffrey", "Jeremy", "Jerome", "Jerry", "Jesse", "Jessie", "Jesus", "Jim", "Jimmie", "Jimmy", "Joe", "Joel", "John", "Johnnie", "Johnny", "Jon", "Jonas", "Jonathan", "Jordan", "Jorge", "Jose", "Joseph", "Joshua", "Juan", "Julian", "Julio", "Justin",
	"Karl", "Keith", "Kelly", "Ken", "Kenneth", "Kent", "Kevin", "Kirk", "Kurt", "Kyle",
	"Lance", "Larry", "Lars", "Lawrence", "Lee", "Lennie", "Leo", "Leon", "Leonard", "Leroy", "Leslie", "Lester", "Lewis", "Lloyd", "Lonnie", "Louis", "Luis",
	"Manuel", "Marc", "Marcus", "Mario", "Mark", "Marshall", "Martin", "Marvin", "Maurice", "Matthew", "Max", "Melvin", "Michael", "Mickey", "Miguel", "Mike", "Milton", "Mitch", "Mitchell", "Morris",
	"Nathan", "Nathaniel", "Ned", "Neil", "Nelson", "Nicholas", "Nick", "Norman",
	"Oliver", "Orlando", "Oscar",
	"Pablo", "Patrick", "Paul", "Pedro", "Perry", "Pete", "Peter", "Phil", "Phillip", "Preston",
	"Quentin",
	"Rafael", "Ralph", "Ramon", "Randall", "Randy", "Raul", "Ray", "Raymond", "Reginald", "Rene", "Ricardo", "Richard", "Rick", "Ricky", "Rob", "Robert", "Roberto", "Rodney", "Roger", "Roland", "Ron", "Ronald", "Ronnie", "Ross", "Roy", "Ruben", "Rudy", "Russell", "Ryan",
	"Salvador", "Sam", "Samuel", "Saul", "Scott", "Sean", "Seth", "Sergio", "Shane", "Shaun", "Shawn", "Sidney", "Stan", "Stanley", "Stephen", "Steve", "Steven", "Stuart",
	"Ted", "Terrance", "Terrence", "Terry", "Theodore", "Thomas", "Tim", "Timothy", "Toby", "Todd", "Tom", "Tommy", "Tony", "Tracy", "Travis", "Trevor", "Troy", "Tyler", "Tyrone",
	"Ulrich",
	"Val", "Vernon", "Vince", "Vincent", "Vinnie", "Victor", "Virgil",
	"Wade", "Wallace", "Walter", "Warren", "Wayne", "Wesley", "Willard", "William", "Willie",
	"Xavier",
	# Y
	"Zachary",
]

# alpha10.1 added new female first names
const FEMALE_FIRST_NAMES: Array = [
	"Abigail", "Agnes", "Ali", "Alice", "Alicia", "Allison", "Alma", "Amanda", "Amber", "Amy", "Andrea", "Angela", "Anita", "Ana", "Ann", "Anna", "Anne", "Annette", "Annie", "April", "Arlene", "Ashley", "Audrey",
	"Barbara", "Beatrice", "Becky", "Belinda", "Bernice", "Bertha", "Bessie", "Beth", "Betty", "Beverly", "Billie", "Bobbie", "Bonnie", "Brandy", "Brenda", "Britanny",
	"Carla", "Carmen", "Carol", "Carole", "Caroline", "Carolyn", "Carrie", "Cassandra", "Cassie", "Cathy", "Catherine", "Charlene", "Charlotte", "Cherie", "Cheryl", "Christina", "Christine", "Christy", "Cindy", "Claire", "Clara", "Claudia", "Colleen", "Connie", "Constance", "Courtney", "Cris", "Crissie", "Crystal", "Cynthia",
	"Daisy", "Dana", "Danielle", "Darlene", "Dawn", "Deanna", "Debbie", "Deborah", "Debrah", "Delores", "Denise", "Diana", "Diane", "Donna", "Dolores", "Dora", "Doris", "Dorothy",
	"Edith", "Edna", "Eileen", "Elaine", "Elayne", "Eleanor", "Eleonor", "Elizabeth", "Ella", "Ellen", "Elsie", "Emily", "Emma", "Erica", "Erika", "Erin", "Esther", "Ethel", "Eva", "Evelyn",
	"Felicia", "Fiona", "Florence", "Fran", "Frances",
	"Gail", "Georgia", "Geraldine", "Gertrude", "Gina", "Ginger", "Gladys", "Glenda", "Gloria", "Grace", "Gwendolyn",
	"Hazel", "Heather", "Heidi", "Helen", "Helena", "Hilary", "Hilda", "Holly", "Holy",
	"Ida", "Ingrid", "Irene", "Irma", "Isabela",
	"Jackie", "Jacqueline", "Jamie", "Jane", "Janet", "Janice", "Jean", "Jeanne", "Jeanette", "Jennie", "Jennifer", "Jenny", "Jess", "Jessica", "Jessie", "Jill", "Jo", "Joan", "Joana", "Joanne", "Josephine", "Joy", "Joyce", "Juanita", "Judith", "Judy", "Julia", "Julie", "June",
	"Karen", "Kate", "Katherine", "Kathleen", "Kathy", "Kathryn", "Katie", "Katrina", "Kay", "Kelly", "Kim", "Kimberly", "Kira", "Kristen", "Kristin", "Kristina",
	"Laura", "Lauren", "Laurie", "Lea", "Lena", "Leona", "Leonor", "Leslie", "Lillian", "Lillie", "Linda", "Lindsay", "Lisa", "Liz", "Lois", "Loretta", "Lori", "Lorraine", "Louise", "Lucia", "Lucille", "Lucy", "Lydia", "Lynn",
	"Mabel", "Mae", "Maggie", "Marcia", "Margaret", "Margie", "Maria", "Marian", "Marie", "Marion", "Marjorie", "Marlene", "Marsha", "Martha", "Mary", "Marylin", "Mary-Ann", "Mattie", "Maureen", "Maxine", "Megan", "Melanie", "Melinda", "Melissa", "Michele", "Mildred", "Millie", "Minnie", "Miriam", "Misty", "Molly", "Monica", "Myrtle",
	"Naomi", "Nancy", "Natalie", "Nelly", "Nicole", "Nina", "Nora", "Norma",
	"Olga", "Ophelia",
	"Paquita", "Page", "Pamela", "Patricia", "Patsy", "Patty", "Paula", "Pauline", "Pearl", "Peggy", "Penny", "Phyllis", "Priscilla",
	# Q
	"Rachel", "Ramona", "Raquel", "Rebecca", "Regina", "Renee", "Rhonda", "Rita", "Roberta", "Robin", "Rosa", "Rose", "Rosemary", "Ruby", "Ruth",
	"Sabrina", "Sally", "Samantha", "Sandra", "Sara", "Sarah", "Shannon", "Sharon", "Sheila", "Shelly", "Sherry", "Shirley", "Sofia", "Sonia", "Stacey", "Stacy", "Stella", "Stephanie", "Sue", "Susan", "Suzanne", "Sylvia",
	"Tabatha", "Tamara", "Tammy", "Tanya", "Tara", "Terri", "Terry", "Tess", "Thelma", "Theresa", "Tiffany", "Tina", "Toni", "Tonya", "Tori", "Tracey", "Tracy",
	# U
	"Valerie", "Vanessa", "Velma", "Vera", "Veronica", "Vickie", "Victoria", "Viola", "Violet", "Virginia", "Vivian",
	"Wanda", "Wendy", "Willie", "Wilma", "Winona",
	# X
	"Yolanda", "Yvone",
	"Zora",
]

# alpha10.1 added new names
const LAST_NAMES: Array = [
	"Adams", "Alexander", "Allen", "Anderson", "Austin",
	"Bailey", "Baker", "Barnes", "Bell", "Bennett", "Bent", "Black", "Bradley", "Brown", "Brooks", "Bryant", "Bush", "Butler",
	"Campbell", "Carpenter", "Carter", "Clark", "Coleman", "Collins", "Cook", "Cooper", "Cordell", "Cox",
	"Davis", "Diaz", "Dobbs",
	"Edwards", "Engels", "Evans",
	"Finch", "Flores", "Ford", "Forrester", "Foster",
	"Garcia", "Gates", "Gonzales", "Gonzalez", "Gray", "Green", "Griffin",
	"Hall", "Harris", "Hayes", "Henderson", "Hernandez", "Hewlett", "Hill", "Holtz", "Howard", "Hughes",
	"Irvin",
	"Jackson", "James", "Jenkins", "Johnson", "Jones",
	"Kelly", "Kennedy", "King",
	"Lambert", "Lesaint", "Lee", "Lewis", "Long", "Lopez",
	"Malory", "Martin", "Martinez", "McAllister", "McGready", "Miller", "Mitchell", "Moore", "Morgan", "Morris", "Murphy",
	"Nelson", "Norton",
	"O'Brien", "Oswald",
	"Parker", "Patterson", "Paul", "Perez", "Perry", "Peterson", "Phillips", "Pitt", "Powell", "Price",
	"Quinn",
	"Ramirez", "Reed", "Reeves", "Richardson", "Rivera", "Roberts", "Robinson", "Rockwell", "Rodriguez", "Rogers", "Robertson", "Ross", "Russell",
	"Sanchez", "Sanders", "Scott", "Simmons", "Smith", "Stevens", "Steward", "Stewart",
	"Tarver", "Taylor", "Thomas", "Thompson", "Torres", "Turner",
	"Ulrich",
	"Vance",
	"Walker", "Ward", "Walters", "Washington", "Watson", "White", "Williams", "Wilson", "Wood", "Wright",
	# X
	"Young",
	# Z
]


func give_name_to_actor(roller: DiceRoller, actor: Actor) -> void:
	if actor.model.doll_body.is_male:
		give_name_to_actor_with(roller, actor, MALE_FIRST_NAMES, LAST_NAMES)
	else:
		give_name_to_actor_with(roller, actor, FEMALE_FIRST_NAMES, LAST_NAMES)


func give_name_to_actor_with(roller: DiceRoller, actor: Actor, first_names: Array, last_names: Array) -> void:
	actor.is_proper_name = true
	var random_name: String = first_names[roller.roll(0, first_names.size())] + " " + last_names[roller.roll(0, last_names.size())]
	actor.name = random_name


# Actor skills helpers

func give_random_skills_to_actor(roller: DiceRoller, actor: Actor, count: int) -> void:
	for i in count:
		give_random_skill_to_actor(roller, actor)


func give_random_skill_to_actor(roller: DiceRoller, actor: Actor) -> void:
	var random_id: int
	if actor.model.abilities.is_undead:
		random_id = Skills.roll_undead(roller)
	else:
		random_id = Skills.roll_living(roller)
	give_starting_skill_to_actor(actor, random_id)


func give_starting_skill_to_actor(actor: Actor, skill_id: int) -> void:
	if actor.sheet.skill_table.get_skill_level(skill_id) >= Skills.max_skill_level(skill_id):
		return

	actor.sheet.skill_table.add_or_increase_skill(skill_id)

	# recompute starting stats.
	recompute_actor_starting_stats(actor)


func recompute_actor_starting_stats(actor: Actor) -> void:
	actor.hit_points = rules.actor_max_hps(actor)
	actor.stamina_points = rules.actor_max_sta(actor)
	actor.food_points = rules.actor_max_food(actor)
	actor.sleep_points = rules.actor_max_sleep(actor)
	actor.sanity = rules.actor_max_sanity(actor)
	if actor.inventory != null:
		actor.inventory.max_capacity = rules.actor_max_inv(actor)


# Common map objects

func make_obj_wooden_door() -> DoorWindow:
	var door: DoorWindow = DoorWindow.new("wooden door", GameImages.OBJ_WOODEN_DOOR_CLOSED, GameImages.OBJ_WOODEN_DOOR_OPEN, GameImages.OBJ_WOODEN_DOOR_BROKEN, DoorWindow.BASE_HITPOINTS)
	door.gives_wood = true
	return door


func make_obj_hospital_door() -> DoorWindow:
	var door: DoorWindow = DoorWindow.new("door", GameImages.OBJ_HOSPITAL_DOOR_CLOSED, GameImages.OBJ_HOSPITAL_DOOR_OPEN, GameImages.OBJ_HOSPITAL_DOOR_BROKEN, DoorWindow.BASE_HITPOINTS)
	door.gives_wood = true
	return door


func make_obj_char_door() -> DoorWindow:
	return DoorWindow.new("CHAR door", GameImages.OBJ_CHAR_DOOR_CLOSED, GameImages.OBJ_CHAR_DOOR_OPEN, GameImages.OBJ_CHAR_DOOR_BROKEN, 4 * DoorWindow.BASE_HITPOINTS)


func make_obj_glass_door() -> DoorWindow:
	var door: DoorWindow = DoorWindow.new("glass door", GameImages.OBJ_GLASS_DOOR_CLOSED, GameImages.OBJ_GLASS_DOOR_OPEN, GameImages.OBJ_GLASS_DOOR_BROKEN, DoorWindow.BASE_HITPOINTS / 4)
	door.is_material_transparent = true
	door.breaks_when_fired_through = true
	return door


func make_obj_iron_door() -> DoorWindow:
	var door: DoorWindow = DoorWindow.new("iron door", GameImages.OBJ_IRON_DOOR_CLOSED, GameImages.OBJ_IRON_DOOR_OPEN, GameImages.OBJ_IRON_DOOR_BROKEN, 8 * DoorWindow.BASE_HITPOINTS)
	door.is_an = true
	return door


func make_obj_window() -> DoorWindow:
	# windows as transparent doors.
	var door: DoorWindow = DoorWindow.new("window", GameImages.OBJ_WINDOW_CLOSED, GameImages.OBJ_WINDOW_OPEN, GameImages.OBJ_WINDOW_BROKEN, DoorWindow.BASE_HITPOINTS / 4)
	door.is_window = true
	door.is_material_transparent = true
	door.gives_wood = true
	door.breaks_when_fired_through = true
	return door


func make_obj_fence(fence_image_id: String, burnable: MapObject.Fire = MapObject.Fire.UNINFLAMMABLE, hit_points: int = DoorWindow.BASE_HITPOINTS * 10) -> MapObject:
	var obj: MapObject = MapObject.new("fence", fence_image_id, MapObject.Break.BREAKABLE, burnable, hit_points)
	obj.is_material_transparent = true
	obj.jump_level = 1
	obj.gives_wood = true
	obj.stand_on_fov_bonus = true
	return obj


# alpha10
func make_obj_wire_fence(fence_image_id: String, burnable: MapObject.Fire = MapObject.Fire.UNINFLAMMABLE, hit_points: int = DoorWindow.BASE_HITPOINTS) -> MapObject:
	var obj: MapObject = MapObject.new("fence", fence_image_id, MapObject.Break.BREAKABLE, burnable, hit_points)
	obj.is_material_transparent = true
	obj.jump_level = 1
	obj.stand_on_fov_bonus = true
	return obj


func make_obj_iron_fence(fence_image_id: String) -> MapObject:
	var obj: MapObject = MapObject.new("iron fence", fence_image_id)
	obj.is_material_transparent = true
	obj.is_an = true
	return obj


# alpha10.1 added param is_breakable
func make_obj_iron_gate(gate_image_id: String, is_breakable: bool = true) -> MapObject:
	var obj: MapObject = MapObject.new("iron gate", gate_image_id,
		MapObject.Break.BREAKABLE if is_breakable else MapObject.Break.UNBREAKABLE,
		MapObject.Fire.UNINFLAMMABLE,
		DoorWindow.BASE_HITPOINTS * 20 if is_breakable else 0)
	obj.is_material_transparent = true
	obj.is_an = true
	return obj


func make_obj_small_fortification(image_id: String) -> Fortification:
	var obj: Fortification = Fortification.new("small fortification", image_id, Fortification.SMALL_BASE_HITPOINTS)
	obj.is_material_transparent = true
	obj.gives_wood = true
	obj.is_movable = true
	obj.weight = 4
	obj.jump_level = 1
	return obj


func make_obj_large_fortification(image_id: String) -> Fortification:
	var obj: Fortification = Fortification.new("large fortification", image_id, Fortification.LARGE_BASE_HITPOINTS)
	obj.gives_wood = true
	return obj


func make_obj_tree(tree_image_id: String) -> MapObject:
	var obj: MapObject = MapObject.new("tree", tree_image_id, MapObject.Break.BREAKABLE, MapObject.Fire.BURNABLE, DoorWindow.BASE_HITPOINTS * 10)
	obj.gives_wood = true
	return obj


const CARS: Array = [GameImages.OBJ_CAR1, GameImages.OBJ_CAR2, GameImages.OBJ_CAR3, GameImages.OBJ_CAR4]


## Makes a new wrecked car of a random model.
func make_obj_wrecked_car(roller: DiceRoller) -> MapObject:
	return make_obj_wrecked_car_of(CARS[roller.roll(0, CARS.size())])


## Makes a new wrecked car : transparent, not walkable but jumpable, movable.
func make_obj_wrecked_car_of(car_image_id: String) -> MapObject:
	var obj: MapObject = MapObject.new("wrecked car", car_image_id)
	obj.break_state = MapObject.Break.BROKEN
	obj.is_material_transparent = true
	obj.jump_level = 1
	obj.is_movable = true
	obj.weight = 100
	obj.stand_on_fov_bonus = true
	return obj


func make_obj_shelf(shelf_image_id: String) -> MapObject:
	var obj: MapObject = MapObject.new("shelf", shelf_image_id, MapObject.Break.BREAKABLE, MapObject.Fire.UNINFLAMMABLE, DoorWindow.BASE_HITPOINTS)
	obj.is_container = true
	obj.gives_wood = true
	obj.is_movable = true
	obj.weight = 6
	return obj


func make_obj_bench(bench_image_id: String) -> MapObject:
	var obj: MapObject = MapObject.new("bench", bench_image_id, MapObject.Break.BREAKABLE, MapObject.Fire.UNINFLAMMABLE, DoorWindow.BASE_HITPOINTS * 2)
	obj.is_material_transparent = true
	obj.jump_level = 1
	obj.is_couch = true
	obj.gives_wood = true
	return obj


func make_obj_iron_bench(bench_image_id: String) -> MapObject:
	var obj: MapObject = MapObject.new("iron bench", bench_image_id)
	obj.is_material_transparent = true
	obj.jump_level = 1
	obj.is_couch = true
	obj.is_an = true
	return obj


func make_obj_bed(bed_image_id: String) -> MapObject:
	var obj: MapObject = MapObject.new("bed", bed_image_id, MapObject.Break.BREAKABLE, MapObject.Fire.UNINFLAMMABLE, DoorWindow.BASE_HITPOINTS * 2)
	obj.is_material_transparent = true
	obj.is_walkable = true
	obj.is_couch = true
	obj.gives_wood = true
	obj.is_movable = true
	obj.weight = 6
	return obj


func make_obj_wardrobe(wardrobe_image_id: String) -> MapObject:
	var obj: MapObject = MapObject.new("wardrobe", wardrobe_image_id, MapObject.Break.BREAKABLE, MapObject.Fire.UNINFLAMMABLE, DoorWindow.BASE_HITPOINTS * 6)
	obj.is_material_transparent = false
	obj.is_container = true
	obj.gives_wood = true
	obj.is_movable = true
	obj.weight = 10
	return obj


func make_obj_drawer(drawer_image_id: String) -> MapObject:
	var obj: MapObject = MapObject.new("drawer", drawer_image_id, MapObject.Break.BREAKABLE, MapObject.Fire.UNINFLAMMABLE, DoorWindow.BASE_HITPOINTS)
	obj.is_material_transparent = true
	obj.is_container = true
	obj.gives_wood = true
	obj.is_movable = true
	obj.weight = 6
	return obj


func make_obj_table(table_image_id: String) -> MapObject:
	var obj: MapObject = MapObject.new("table", table_image_id, MapObject.Break.BREAKABLE, MapObject.Fire.UNINFLAMMABLE, DoorWindow.BASE_HITPOINTS)
	obj.is_material_transparent = true
	obj.jump_level = 1
	obj.gives_wood = true
	obj.is_movable = true
	obj.weight = 2
	return obj


func make_obj_chair(chair_image_id: String) -> MapObject:
	var obj: MapObject = MapObject.new("chair", chair_image_id, MapObject.Break.BREAKABLE, MapObject.Fire.UNINFLAMMABLE, DoorWindow.BASE_HITPOINTS / 3)
	obj.is_material_transparent = true
	obj.jump_level = 1
	obj.gives_wood = true
	obj.is_movable = true
	obj.weight = 1
	return obj


func make_obj_night_table(night_table_image_id: String) -> MapObject:
	var obj: MapObject = MapObject.new("night table", night_table_image_id, MapObject.Break.BREAKABLE, MapObject.Fire.UNINFLAMMABLE, DoorWindow.BASE_HITPOINTS / 3)
	obj.is_material_transparent = true
	obj.jump_level = 1
	obj.gives_wood = true
	obj.is_movable = true
	obj.weight = 1
	return obj


func make_obj_fridge(fridge_image_id: String) -> MapObject:
	var obj: MapObject = MapObject.new("fridge", fridge_image_id, MapObject.Break.BREAKABLE, MapObject.Fire.UNINFLAMMABLE, DoorWindow.BASE_HITPOINTS * 6)
	obj.is_container = true
	obj.is_movable = true
	obj.weight = 10
	return obj


func make_obj_junk(junk_image_id: String) -> MapObject:
	var obj: MapObject = MapObject.new("junk", junk_image_id, MapObject.Break.BREAKABLE, MapObject.Fire.UNINFLAMMABLE, DoorWindow.BASE_HITPOINTS)
	obj.is_plural = true
	obj.is_material_transparent = true
	obj.is_movable = true
	obj.gives_wood = true
	obj.weight = 6
	return obj


func make_obj_barrels(barrels_image_id: String) -> MapObject:
	var obj: MapObject = MapObject.new("barrels", barrels_image_id, MapObject.Break.BREAKABLE, MapObject.Fire.UNINFLAMMABLE, 2 * DoorWindow.BASE_HITPOINTS)
	obj.is_plural = true
	obj.is_material_transparent = true
	obj.is_movable = true
	obj.gives_wood = true
	obj.weight = 10
	return obj


func make_obj_power_generator(off_image_id: String, on_image_id: String) -> PowerGenerator:
	return PowerGenerator.new("power generator", off_image_id, on_image_id)


func make_obj_board(image_id: String, text: PackedStringArray) -> Board:
	return Board.new("board", image_id, text)


# Common tile decorations

func decorate_outside_walls(map: Map, rect: Rect2i, deco_fn: Callable) -> void:
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var tile: Tile = map.get_tile_at(x, y)
			if tile.model.is_walkable:
				continue
			if tile.is_inside:
				continue

			var deco = deco_fn.call(x, y)
			if deco != null:
				tile.add_decoration(deco)


# Common items

func make_item_bandages() -> Item:
	var it: Item = ItemMedicine.new(game.game_items.bandage())
	it.quantity = rules.roll(1, game.game_items.bandage().stacking_limit)
	return it


func make_item_medikit() -> Item:
	return ItemMedicine.new(game.game_items.medikit())


func make_item_pills_sta() -> Item:
	var it: Item = ItemMedicine.new(game.game_items.pills_sta())
	it.quantity = rules.roll(1, game.game_items.pills_sta().stacking_limit)
	return it


func make_item_pills_slp() -> Item:
	var it: Item = ItemMedicine.new(game.game_items.pills_slp())
	it.quantity = rules.roll(1, game.game_items.pills_slp().stacking_limit)
	return it


func make_item_pills_san() -> Item:
	var it: Item = ItemMedicine.new(game.game_items.pills_san())
	it.quantity = rules.roll(1, game.game_items.pills_san().stacking_limit)
	return it


func make_item_pills_antiviral() -> Item:
	var it: Item = ItemMedicine.new(game.game_items.pills_antiviral())
	it.quantity = rules.roll(1, game.game_items.pills_antiviral().stacking_limit)
	return it


func make_item_groceries() -> Item:
	# FIXME: should be map local time.
	var time_now: int = game.session.world_time.turn_counter

	var max_turns: int = WorldTime.TURNS_PER_DAY * game.game_items.groceries().best_before_days
	var min_turns: int = max_turns / 2
	var fresh_until: int = time_now + rules.roll(min_turns, max_turns)

	return ItemFood.new(game.game_items.groceries(), fresh_until)


func make_item_canned_food() -> Item:
	# canned food not perishable.
	var it: Item = ItemFood.new(game.game_items.canned_food())
	it.quantity = rules.roll(1, game.game_items.canned_food().stacking_limit)
	return it


func make_item_crowbar() -> Item:
	var it: Item = ItemMeleeWeapon.new(game.game_items.crowbar())
	it.quantity = rules.roll(1, game.game_items.crowbar().stacking_limit)
	return it


func make_item_baseball_bat() -> Item:
	return ItemMeleeWeapon.new(game.game_items.baseball_bat())


func make_item_combat_knife() -> Item:
	return ItemMeleeWeapon.new(game.game_items.combat_knife())


func make_item_truncheon() -> Item:
	return ItemMeleeWeapon.new(game.game_items.truncheon())


func make_item_golf_club() -> Item:
	return ItemMeleeWeapon.new(game.game_items.golf_club())


func make_item_iron_golf_club() -> Item:
	return ItemMeleeWeapon.new(game.game_items.iron_golf_club())


func make_item_huge_hammer() -> Item:
	return ItemMeleeWeapon.new(game.game_items.huge_hammer())


func make_item_small_hammer() -> Item:
	return ItemMeleeWeapon.new(game.game_items.small_hammer())


func make_item_jason_myers_axe() -> Item:
	var it: Item = ItemMeleeWeapon.new(game.game_items.unique_jason_myers_axe())
	it.is_unique = true
	return it


func make_item_shovel() -> Item:
	return ItemMeleeWeapon.new(game.game_items.shovel())


func make_item_short_shovel() -> Item:
	return ItemMeleeWeapon.new(game.game_items.short_shovel())


func make_item_wooden_plank() -> ItemBarricadeMaterial:
	return ItemBarricadeMaterial.new(game.game_items.woodenplank())


func make_item_hunting_crossbow() -> Item:
	return ItemRangedWeapon.new(game.game_items.hunting_crossbow())


func make_item_bolts_ammo() -> Item:
	return ItemAmmo.new(game.game_items.ammo_bolts())


func make_item_hunting_rifle() -> Item:
	return ItemRangedWeapon.new(game.game_items.hunting_rifle())


func make_item_light_rifle_ammo() -> Item:
	return ItemAmmo.new(game.game_items.ammo_light_rifle())


func make_item_pistol() -> Item:
	return ItemRangedWeapon.new(game.game_items.pistol())


func make_item_kolt_revolver() -> Item:
	return ItemRangedWeapon.new(game.game_items.kolt_revolver())


func make_item_random_pistol() -> Item:
	return make_item_pistol() if rules.roll_chance(50) else make_item_kolt_revolver()


func make_item_light_pistol_ammo() -> Item:
	return ItemAmmo.new(game.game_items.ammo_light_pistol())


func make_item_shotgun() -> Item:
	return ItemRangedWeapon.new(game.game_items.shotgun())


func make_item_shotgun_ammo() -> Item:
	return ItemAmmo.new(game.game_items.ammo_shotgun())


func make_item_char_light_body_armor() -> Item:
	return ItemBodyArmor.new(game.game_items.char_lt_bodyarmor())


func make_item_biker_gang_jacket(gang_id: int) -> Item:
	match gang_id:
		GameGangs.IDs.BIKER_FREE_ANGELS:
			return ItemBodyArmor.new(game.game_items.free_angels_jacket())
		GameGangs.IDs.BIKER_HELLS_SOULS:
			return ItemBodyArmor.new(game.game_items.hells_souls_jacket())
		_:
			# C# threw; don't hard-crash debug builds, fall back to null.
			push_error("unhandled biker gang %s" % gang_id)
			return null


func make_item_police_jacket() -> Item:
	return ItemBodyArmor.new(game.game_items.police_jacket())


func make_item_police_riot_armor() -> Item:
	return ItemBodyArmor.new(game.game_items.police_riot())


func make_item_hunter_vest() -> Item:
	return ItemBodyArmor.new(game.game_items.hunter_vest())


func make_item_cell_phone() -> Item:
	return ItemTracker.new(game.game_items.cell_phone())


func make_item_spray_paint() -> Item:
	# random color.
	var paint_model: ItemSprayPaintModel
	var roll: int = rules.roll(0, 4)
	match roll:
		0: paint_model = game.game_items.spray_paint1()
		1: paint_model = game.game_items.spray_paint2()
		2: paint_model = game.game_items.spray_paint3()
		3: paint_model = game.game_items.spray_paint4()
		_:
			# C# threw; don't hard-crash debug builds, fall back to paint1.
			push_error("unhandled roll %d" % roll)
			paint_model = game.game_items.spray_paint1()

	return ItemSprayPaint.new(paint_model)


func make_item_stench_killer() -> Item:
	return ItemSprayScent.new(game.game_items.stench_killer())


func make_item_army_rifle() -> Item:
	return ItemRangedWeapon.new(game.game_items.army_rifle())


func make_item_precision_rifle() -> Item:
	return ItemRangedWeapon.new(game.game_items.precision_rifle())


func make_item_heavy_rifle_ammo() -> Item:
	return ItemAmmo.new(game.game_items.ammo_heavy_rifle())


func make_item_army_pistol() -> Item:
	return ItemRangedWeapon.new(game.game_items.army_pistol())


func make_item_heavy_pistol_ammo() -> Item:
	return ItemAmmo.new(game.game_items.ammo_heavy_pistol())


func make_item_army_body_armor() -> Item:
	return ItemBodyArmor.new(game.game_items.army_bodyarmor())


func make_item_army_ration() -> Item:
	# army rations fresh for 5 days.
	var time_now: int = game.session.world_time.turn_counter
	var fresh_until: int = time_now + WorldTime.TURNS_PER_DAY * game.game_items.army_ration().best_before_days

	return ItemFood.new(game.game_items.army_ration(), fresh_until)


func make_item_flashlight() -> Item:
	return ItemLight.new(game.game_items.flashlight())


func make_item_big_flashlight() -> Item:
	return ItemLight.new(game.game_items.big_flashlight())


func make_item_ztracker() -> Item:
	return ItemTracker.new(game.game_items.ztracker())


func make_item_blackops_gps() -> Item:
	return ItemTracker.new(game.game_items.blackops_gps())


func make_item_police_radio() -> Item:
	return ItemTracker.new(game.game_items.police_radio())


func make_item_grenade() -> Item:
	var it: Item = ItemGrenade.new(game.game_items.grenade(), game.game_items.grenade_primed())
	it.quantity = rules.roll(1, game.game_items.grenade().stacking_limit)
	return it


func make_item_bear_trap() -> Item:
	return ItemTrap.new(game.game_items.bear_trap())


func make_item_spikes() -> Item:
	# NOTE: faithful to the C# original : SPIKES quantity is rolled against
	# BARBED_WIRE stacking limit (original quirk).
	var it: Item = ItemTrap.new(game.game_items.spikes())
	it.quantity = rules.roll(1, game.game_items.barbed_wire().stacking_limit)
	return it


func make_item_barbed_wire() -> Item:
	var it: Item = ItemTrap.new(game.game_items.barbed_wire())
	it.quantity = rules.roll(1, game.game_items.barbed_wire().stacking_limit)
	return it


func make_item_book() -> Item:
	return ItemEntertainment.new(game.game_items.book())


func make_item_magazines() -> Item:
	var it: Item = ItemEntertainment.new(game.game_items.magazine())
	it.quantity = rules.roll(1, game.game_items.magazine().stacking_limit)
	return it


# Common tasks

func barricade_doors(map: Map, rect: Rect2i, barricade_level: int) -> void:
	barricade_level = mini(Rules.BARRICADING_MAX, barricade_level)

	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var door: DoorWindow = map.get_map_object_at_xy(x, y) as DoorWindow
			if door == null:
				continue
			door.barricade_points = barricade_level


# Zones

func make_unique_zone(basename: String, rect: Rect2i) -> Zone:
	var zone_name: String = "%s@%d-%d" % [basename, rect.position.x + rect.size.x / 2, rect.position.y + rect.size.y / 2]
	return Zone.new(zone_name, rect)
