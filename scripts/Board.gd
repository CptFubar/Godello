extends Control

var is_receiving_drag_data = true

var lists : Array = []
var list_id_to_container : Dictionary = {}

onready var list_scene := preload("res://scenes/List.tscn")
onready var list_container := $MarginContainer/ListContainerScroll/ListContainer
onready var list_container_scroll := $MarginContainer/ListContainerScroll

func _ready():	
	for n in range(1, 20): # todo: iterate through existing lists
		var list_element = list_scene.instance()
		var list_id = str(n)
		
		var cards := []		
		for c in range(1, 10):
			var id = str(OS.get_ticks_usec())
			var card = CardModel.new(id, list_id, ("Card Title " + id).repeat(c))
			cards.append(card)
		
		var list = ListModel.new(list_id, "List " + list_id, cards)
		list_container.add_child(list_element)
		list_element.set_model(list)

func can_drop_data(mouse_pos, data):
	if data.model.model_type == Model.ModelTypes.LIST:
		is_receiving_drag_data = true

		var list_node = data.origin_node

		if list_node.get_parent() != list_container:
			list_node.get_parent().remove_child(list_node)
			list_container.add_child(list_node)			
			
		if list_container.get_child_count() > 1:
			var closest_list = DragUtils.find_closest_horizontal_child(mouse_pos, list_node, list_container, list_container_scroll)
			
			if closest_list[0]:
				var curr_idx = list_node.get_index()		
				var closest_idx = closest_list[0].get_index()					
				var next_idx = max(0, closest_idx + (-1 if closest_list[1] else 0))
				list_container.move_child(list_node, next_idx)
								
		return true	
		
	is_receiving_drag_data = false
	return false

func drop_data(_pos, data):
	if data.model.model_type == Model.ModelTypes.LIST:
		Events.emit_signal("list_dropped", data)
