extends Node

func _ready():
	pass # Replace with function body.

var effects: = {}

func get_new_id():
	var s := "eid%d"
	var t = randi()
	while effects.has(s % t):
		t += 1
	return s % t


func add_effect(eff):
	var id = get_new_id()
	effects[id] = eff
	eff.id = id
	return id

func add_stored_effect(id, eff):
	effects[id] = eff

func get_effect_by_id(id):
	return effects[id]

func cleanup():
	for id in effects:
		if !effects[id].is_applied:
			remove_id(id)
	pass

func remove_id(id):
	for eff in effects.values():
		if eff.parent == id:
			eff.parent = null
		if eff.sub_effects.has(id):
			eff.sub_effects.erase(id)
	effects.erase(id)
	pass

func serialize():
	cleanup()
	var tmp = {}
	for e in effects.keys():
		tmp[e] = effects[e].serialize()
	return tmp

func deserialize_effect(tmp, caller = null):
	var eff
	match tmp.type:
		'base': eff = base_effect.new(caller)
		'static': eff = static_effect.new(caller)
		'trigger': eff = triggered_effect.new(caller)
		'temp_s': eff = temp_e_simple.new(caller)
		'temp_p': eff = temp_e_progress.new(caller)
		'temp_u': eff = temp_e_upgrade.new(caller)
		'area': eff = area_effect.new(caller)
	eff.deserialize(tmp)
	return eff

func e_createfromtemplate(buff_t, caller = null):
	var template
	var tmp
	if typeof(buff_t) == TYPE_STRING:
		template = Effectdata.effect_table[buff_t]
	else:
		template = buff_t.duplicate()
	match template.type:
		'base': tmp = base_effect.new(caller)
		'static': tmp = static_effect.new(caller)
		'trigger': tmp = triggered_effect.new(caller)
		'temp_s': tmp = temp_e_simple.new(caller)
		'temp_p': tmp = temp_e_progress.new(caller)
		'temp_u': tmp = temp_e_upgrade.new(caller)
		'area': tmp = area_effect.new(caller)
		'oneshot': tmp = oneshot_effect.new(caller)
	tmp.createfromtemplate(template)
	return tmp
	pass

func deserialize(tmp):
	effects.clear()
	for k in tmp.keys():
		var eff = deserialize_effect(tmp)
		effects[k] = eff