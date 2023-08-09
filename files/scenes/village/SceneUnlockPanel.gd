extends Control

onready var charlist = $Panel/heroes/HBoxContainer
onready var scenelist = $Panel/scenes/GridContainer

var selected_char
const char_sprites = {
	rose = 'rose',
	ember = 'emberhappy',
	erika = 'erika',
	iola = 'iola',
	rilu = 'rilu'
}


export var test_mode = false

func _ready():
	hide()
	if input_handler.scene_node == null and test_mode:
		input_handler.initiate_scennode(self)
	$close.connect("pressed", self, 'hide')
	$CloseButton.connect("pressed", self, 'hide')
	for ch in charlist.get_children():
		var cid = ch.name.to_lower()
		ch.set_meta('hero', cid)
		ch.connect('pressed', self, 'select_hero', [cid])
		if char_sprites.has(cid): resources.preload_res("sprite/%s" % char_sprites[cid])
	#TODO full preload of previews is a bad idea! Need to optimise it somehow
	preload_previews()
	if test_mode:
		testmode()
		if resources.is_busy(): yield(resources, "done_work")
		open()

func testmode():
	for cid in state.characters:
		state.unlock_char(cid)
	
#	var tscene = load("res://files/TextSceneNew/TextSystem.tscn")
#	var tnode = tscene.instance()
#	input_handler.scene_node = tnode #will be set on add_child anyway
#	tnode.hide()
#	add_child(tnode)


func preload_previews():
	for event in Explorationdata.scene_sequences:
		var eventdata = Explorationdata.scene_sequences[event]
		if eventdata.has('category') and eventdata.has('preview'):
			resources.preload_res("scene_preview/%s" % eventdata.preview)



func open():
	var def_char = null
	for ch_id in ['rose', 'ember', 'erika', 'iola', 'rilu']:
		var ch = charlist.get_node(ch_id)
		if state.heroes[ch_id].unlocked:
			ch.visible = true
			if def_char == null:
				def_char = ch_id
		else:
			ch.visible = false
	select_hero(def_char)
	input_handler.UnfadeAnimation(self)
	show()


func select_hero(cid):
	if cid == selected_char: return
	selected_char = cid
	for ch in charlist.get_children():
		ch.pressed = (ch.get_meta('hero') == cid)
	rebuild_scene_list()
	if selected_char != 'all': #simple sprite setup. tell me if animated sprite is needed
		var tmp = resources.get_res("sprite/%s" % char_sprites[selected_char]) 
		$panel_hero/hero.texture = tmp
	else:
		$panel_hero/hero.texture = null


func rebuild_scene_list():
	input_handler.ClearContainer(scenelist, ['Button'])
	for event in Explorationdata.scene_sequences:
		var eventdata = Explorationdata.scene_sequences[event]
		if !eventdata.has('category'): continue
		if selected_char == 'all':
			if !state.heroes[eventdata.category].unlocked: continue
		elif eventdata.category != selected_char: continue
		var panel = input_handler.DuplicateContainerTemplate(scenelist, 'Button')
		if state.OldSeqs.has(event):
			panel.set_unlocked(eventdata)
			panel.connect('show_pressed', self, 'show_event', [event])
			continue
		if eventdata.has("initiate_reqs") and state.checkreqs(eventdata.initiate_reqs): #not shown but unlockable
			panel.set_unlockable(eventdata)
			panel.connect('unlocked_pressed', self, 'unlock_show_event', [event])
			continue
		panel.set_unknown()


func show_event(ev):
	globals.run_seq(ev, true)
#	input_handler.OpenClose(input_handler.scene_node)
#	input_handler.scene_node.replay_mode = true
#	input_handler.scene_node.play_scene(ev)


func unlock_show_event(ev):
	var eventdata = Explorationdata.scene_sequences[ev]
	for ch in eventdata.unlock_price:
		var hero = state.heroes[ch]
		hero.friend_points -= eventdata.unlock_price[ch]
	show_event(ev)
	rebuild_scene_list()
