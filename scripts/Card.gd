extends MarginContainer

var model : CardModel setget set_model, get_model
var is_dragged := false setget set_is_dragged
var is_any_card_dragged := false

onready var style_default := preload("res://assets/style_panel_card.tres")
onready var style_dragged := preload("res://assets/style_panel_card_dragged.tres")

onready var content_container := $CardContent
onready var content_padding_container := $CardContent/InnerPadding
onready var title_label := $CardContent/InnerPadding/HBoxContainer/Title
onready var edit_icon := $CardContent/InnerPadding/HBoxContainer/EditIcon
onready var split := $CardContent/InnerPadding/HBoxContainer/Split

onready var card_drag_preview := preload("res://scenes/CardPreview.tscn")

func _ready():
	Events.connect("card_dragged", self, "_on_card_dragged")
	Events.connect("card_dropped", self, "_on_card_dropped")
	
	split.set_visible(true)
	edit_icon.set_visible(false)

func set_model(_model : CardModel):
	model = _model
	title_label.set_text(model.title)

func get_model():
	return model

func set_is_dragged(value := true):	
	if value:
		content_container.set("custom_styles/panel", style_dragged)		
		title_label.set_visible_characters(0)		
		set("mouse_filter", MOUSE_FILTER_PASS)		
	else:
		content_container.set("custom_styles/panel", style_default)		
		title_label.set_visible_characters(-1)		
		set("mouse_filter", MOUSE_FILTER_STOP)
		
	is_dragged = value

func get_drag_data(_pos):	
	var card = card_drag_preview.instance()
	get_parent().add_child(card)
	card.set_data(self, get_model())
	get_parent().remove_child(card)
	set_drag_preview(card)
	
	set_is_dragged()
	_invert_edit_icon_visibility()
	
	Events.emit_signal("card_dragged", self, get_model())
	
	return card
	
func _invert_edit_icon_visibility():
	edit_icon.set_visible(not edit_icon.is_visible())
	split.set_visible(not split.is_visible())

func _on_Card_mouse_entered():
	if not is_dragged and not is_any_card_dragged:
		_invert_edit_icon_visibility()

func _on_Card_mouse_exited():
	if not is_dragged and not is_any_card_dragged:
		_invert_edit_icon_visibility()

func _on_card_dragged(_node, _model):
	is_any_card_dragged = true
	set("mouse_filter", MOUSE_FILTER_IGNORE)
	
func _on_card_dropped(_model):
	is_any_card_dragged = false
	set("mouse_filter", MOUSE_FILTER_STOP)
