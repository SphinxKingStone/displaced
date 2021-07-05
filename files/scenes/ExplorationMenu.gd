extends Control

export var test_mode = false
var location = 'village'
var area = null


onready var arealist = $ExplorationSelect/ScrollContainer/VBoxContainer
onready var areapanel = $ExplorationSelect/Panel
onready var areadesc = $ExplorationSelect/Panel/RichTextLabel
onready var partylist = $ExplorationOngoing/VBoxContainer
onready var reservelist = $ExplorationOngoing/HBoxContainer



func _ready():
	$ExplorationSelect/Panel/Button.connect("pressed", self, "start_area")
	$ExplorationOngoing/StartButton.connect("pressed", self, "advance_area")
	$ExplorationOngoing/CancelButton.connect("pressed", self, "abandon_area")
	$ExplorationOngoing/CloseButton.connect('pressed', self, 'hide')
	$ExplorationSelect/CloseButton.connect('pressed', self, 'hide')
	if test_mode: 
		if resources.is_busy(): yield(resources, "done_work")
		test()


func test():
	for cid in state.characters:
		state.unlock_char(cid)
	location = 'forest'
	area = 'forestelves'
#	show()
	open_mission()

func set_location(loc_code):
	location = loc_code
	if typeof(Explorationdata.locations[location].background) == TYPE_STRING:
		$ExplorationSelect/Image.texture = resources.get_res("bg/%s" % Explorationdata.locations[location].background)
	else:
		$ExplorationSelect/Image.texture = Explorationdata.locations[location].background


func show():
	.show()
	input_handler.explore_node = self
	if state.activearea != null and Explorationdata.areas[state.activearea].category == location:
		area = state.activearea
		open_mission()
	else:
		open_explore()


func open_explore():
	$ExplorationOngoing.visible = false
	$ExplorationSelect.visible = true
	areapanel.visible = false
	$ExplorationSelect/Image.texture = resources.get_res("bg/%s" % Explorationdata.locations[location].background)
	
	input_handler.ClearContainer(arealist)
	for a in Explorationdata.areas:
		var areadata = Explorationdata.areas[a]
		if areadata.category != location: continue
		if !state.checkreqs(areadata.requirements): continue
		if state.areaprogress[a].completed: continue
		var panel = input_handler.DuplicateContainerTemplate(arealist)
		panel.text = areadata.name
		panel.set_meta('area', a)
		panel.connect('pressed', self, 'select_area', [a])
	for a in Explorationdata.areas:
		var areadata = Explorationdata.areas[a]
		if areadata.category != location: continue
		if !state.checkreqs(areadata.requirements): continue
		if !state.areaprogress[a].completed: continue
		var panel = input_handler.DuplicateContainerTemplate(arealist)
		panel.text = areadata.name + " ✓������"
		panel.set_meta('area', a)
		panel.connect('pressed', self, 'select_area', [a])


func select_area(area_code):
	area = area_code
	for node in arealist.get_children():
		node.pressed = (area == node.get_meta('area'))
	build_area_description()


func build_area_description():
	var areadata = Explorationdata.areas[area]
	areapanel.visible = true
	if areadata.has('description'):
#		areadesc.visible = true
		areadesc.bbcode_text = areadata.description + "\nRecommended level: %d" % areadata.level
	else:
		areadesc.bbcode_text = "Recommended level: %d" % areadata.level
#		areadesc.visible = false
	areapanel.get_node("CheckBox").pressed = false
	areapanel.get_node("CheckBox").visible = state.areaprogress[area].completed


func start_area():
	state.start_area(area, areapanel.get_node("CheckBox").pressed)
	open_mission()


func open_mission():
	$ExplorationOngoing.visible = true
	$ExplorationSelect.visible = false
	build_party()
	build_area_info()
	if area != state.activearea:
		print("warning - opened not active area")


func build_party():
	var party_count = 0
	var reserve_count = 0
	for i in range(3):
		partylist.get_child(i).disabled = true
		var node = partylist.get_child(i).get_node('TextureRect')
		node.texture = null
		node.parent_node = self
		node.dragdata = null
	for i in range(6):
		var node = reservelist.get_child(i)
		node.texture = null
		node.parent_node = self
		node.dragdata = null
	
	for ch in state.characters:
		var hero = state.heroes[ch]
		if !hero.unlocked: continue
		if hero.position != null:
			var node = partylist.get_child(hero.position - 1)
			node.disabled = false
			if node.is_connected('pressed', self, 'show_info'):
				node.disconnect('pressed', self, 'show_info')
			node.connect('pressed', self, 'show_info', [ch])
			node.get_node('TextureRect').texture = hero.portrait()
			node.get_node('TextureRect').dragdata = ch
			party_count += 1
		else:
			var node = reservelist.get_child(reserve_count)
			node.texture = hero.portrait()
			node.dragdata = ch
			reserve_count += 1
	
	$ExplorationOngoing/StartButton.disabled = (party_count == 0)


func show_info(ch_id):
	var node = input_handler.get_spec_node(input_handler.NODE_SLAVEPANEL)
	node.open(state.heroes[ch_id])


func build_area_info():
	var areadata = Explorationdata.areas[area]
	var areastate = state.areaprogress[area]
	var text = areadata.name + '\n'
	if areadata.has('description'):
		text += areadata.description + '\n'
	text += "Level: %d \n" % areastate.level
	text += "Stage: %d/%d" % [areastate.stage, areadata.stages]
	$ExplorationOngoing/RichTextLabel.bbcode_text = text


func abandon_area():
	input_handler.get_spec_node(input_handler.NODE_CONFIRMPANEL, [self, 'abandon_area_confirm', tr('ABANDONAREA')])


func abandon_area_confirm():
	state.abandon_area()
	open_explore()


func advance_area():
	var areadata = Explorationdata.areas[area]
	var areastate = state.areaprogress[area]
	#2add generic scene check
#	areastate.stage += 1
	if areastate.stage > areadata.stages:
		finish_area()
	else:
		var stagedata
		if areadata.stagedenemies.has(areastate.stage):
			stagedata = areadata.stagedenemies[areastate.stage]
			if stagedata.has('enemy'):
				#predescribed combat
				var party = Enemydata.predeterminatedgroups[stagedata.enemy].group #not forget to change format of those groups from battlefield dirs to arrays of battlefield dirs due to waves implementation
				var level = areastate.level
				if stagedata.has('level'):
					level += stagedata.level
				var bg = Explorationdata.locations[location].background
				if areadata.has('image') and areadata.image != null and areadata.image != "":
					bg = areadata.image
				#2add set sound
				input_handler.combat_node.show()
				input_handler.combat_node.start_combat(party, level, bg)
				
			elif stagedata.has('scene'):
				#fixed scene
				#2move to globals method
				input_handler.OpenClose(input_handler.scene_node)
				input_handler.scene_node.replay_mode = state.OldEvents.has(stagedata.scene)
				input_handler.scene_node.play_scene(stagedata.scene)
				
				yield(input_handler.scene_node, "scene_end")
				areastate.stage += 1
				advance_area()
		else:
			#random combat
			var tmp
			var arr = []
			for group in areadata.enemygroups:
				var groupdata = Enemydata.randomgroups[group]
				if !state.checkreqs(groupdata.reqs):  continue
				arr.push_back({value = group, weight = groupdata.weight})
			tmp = input_handler.weightedrandom(arr).value
			var party = Enemydata.randomgroups[tmp].units #not forget to change format of those groups from battlefield dirs to arrays of battlefield dirs due to waves implementation
			var level = areastate.level
			var bg = Explorationdata.locations[location].background
			if areadata.has('image') and areadata.image != null and areadata.image != "":
				bg = areadata.image
			#2add set sound
			input_handler.combat_node.show()
			input_handler.combat_node.start_combat(party, level, bg)


func finish_area():
	state.complete_area()
	open_explore()


func combat_win():
	var areadata = Explorationdata.areas[area]
	var areastate = state.areaprogress[area]
	#2add generic scene check
	areastate.stage += 1
	if areastate.stage > areadata.stages:
		finish_area()
	else:
		build_area_info()


func combat_loose():
	var areastate = state.areaprogress[area]
	if areastate.stage == 1:
		state.abandon_area()
	else:
		pass
	hide()


func hide():
	input_handler.map_node.update_map()
	.hide()
