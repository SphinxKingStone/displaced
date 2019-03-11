extends Node

var worker = preload("res://files/scripts/worker.gd");

var date = 1
var daytime = 0

var newgame = false

#resources
var itemidcounter = 0
var heroidcounter = 0
var workeridcounter = 0
var money = 0
var food = 50
var townupgrades = {}
var workers = {}
var heroes = {}
var items = {}
var tasks = []
var materials = {} setget materials_set
var lognode 
var oldmaterials = {}
var unlocks = []

var combatparty = {1 : null, 2 : null, 3 : null, 4 : null, 5 : null, 6 : null}

var CurrentTextScene
var CurrentScreen
var CurrentLine

var heroguild = []

var OldEvents = {};
var CurEvent = ""; #event name
var CurBuild;
var keyframes = [];

func _init():
	oldmaterials = materials.duplicate()

func materials_set(value):
	var text = ''
	for i in value:
		if oldmaterials.has(i) == false || oldmaterials[i] != value[i]:
			if oldmaterials.has(i) == false:
				oldmaterials[i] = 0
			else:
				if oldmaterials[i] - value[i] < 0:
					text += 'Gained '
					input_handler.emit_signal("MaterialObtained", i)
				else:
					text += "Lost "
				text += str(value[i] - oldmaterials[i]) + ' {color=yellow|' + Items.Materials[i].name + '}'
				logupdate(text)
	materials = value
	oldmaterials = materials.duplicate()

func logupdate(text):
	if globals.get_tree().get_root().has_node("LogPanel/RichTextLabel") == false:
		return
	lognode = globals.get_tree().get_root().get_node("LogPanel/RichTextLabel")
	text = lognode.bbcode_text + '\n' + text
	
	#lognode.bbcode_text += '\n' + 
	lognode.bbcode_text = globals.TextEncoder(text)

func assignworker(data):
	data.worker.task = data
	if data.instrument != null:
		data.instrument.task = data
	tasks.append(data)

func stoptask(data):
	data.worker.task = null
	data.instrument.task = null
	tasks.erase(data)

func stopworkertask(worker):
	var data = gettaskfromworker(worker)
	if data != false:
		stoptask(data)

func gettaskfromworker(worker):
	for i in tasks:
		if i.worker == worker:
			return i
	return false

func GetWorkerLimit():
	var value
	if townupgrades.has("houses") == false:
		value = 3
	else:
		value = globals.upgradelist.houses.levels[townupgrades.houses].limitchange
	return value

func StoreEvent (nm):
	OldEvents[nm] = date;

func FinishEvent():
	if CurEvent == "" or CurEvent == null:return;
	StoreEvent(CurEvent);
	CurEvent = "";
	keyframes.clear();


func if_has_money(value):
	return (money >= value);

func if_has_property(prop, value):
	var tmp = get(prop);
	if tmp == null: 
		print ("ERROR: NO PROPERTY IN GAMESTATE %s\n", prop);
		return false;
	return (tmp >= value);

func if_has_hero(name):
	for h in heroes.values():
		if h.name == name: return true;
	return false;

func if_has_material(mat, val):
	if !materials.has(mat): return false;
	return materials[mat] >= val;

func if_has_item(name):
	for i in items.values():
		if i.name == name: return true;
	return false;


func valuecheck(dict):
	if !dict.has('type'): return true;
	match dict['type']:
		"no_check":
			return true;
		"has_money":
			return if_has_money(dict['value']);
		"has_property":
			return if_has_property(dict['prop'], dict['value']);
		"has_hero":
			return if_has_hero(dict['name']);
		"event_finished":
			var tmp = OldEvents.has(dict['name']);
			if tmp and dict.has('delay'):
				tmp = OldEvents[dict['name']] + dict['delay'] <= date;
			return tmp;
		"has_material":
			return if_has_material(dict['material'], dict['value']);
		"date":
			return date >= dict['date'];
		"item":
			return if_has_item(dict['name']);
		"building":
			return CurBuild == dict['value'];
		"gamestart":
			return newgame
		"has_upgrade":
			return if_has_upgrade(dict.name, dict.value)

func if_has_upgrade(upgrade, level):
	if !townupgrades.has(upgrade): return false
	else: return townupgrades[upgrade] >= level

func get_character_by_pos(pos):
	if combatparty[pos] == null: return null;
	return heroes[combatparty[pos]];