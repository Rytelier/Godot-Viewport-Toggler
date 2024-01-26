@tool
extends EditorPlugin

var GizmosMenu : PopupMenu
var VariousMenu : PopupMenu
var Viewport3DControl : Control

var togglerContainer : Control = preload("res://addons/Viewport Toggler/Toggler container.tscn").instantiate()
var toggleGizmos : Control
var toggleVarious : Control

var gizmoIcons : Dictionary = { Light3D="OmniLight3D" }

var settingsFile : ConfigFile

func _enter_tree():
	var found : Array
	FindByName(get_editor_interface().get_editor_main_screen().get_window(), "GizmosMenu", found)
	GizmosMenu = found[0]
	found.clear()
	FindByName(get_editor_interface().get_editor_main_screen().get_window(), "DisplayAdvanced", found)
	VariousMenu = found[0].get_parent()
	found.clear()
	
	FindByClass(get_editor_interface().get_editor_main_screen().get_window(), "Node3DEditorViewport", found)
	Viewport3DControl = found[0].get_child(1)
	
	settingsFile = ConfigFile.new()
	settingsFile.load("res://addons/Viewport Toggler/Settings.cfg")
	var gizmos = settingsFile.get_value("Settings", "Gizmos", [])
	
	Viewport3DControl.add_child(togglerContainer)
	togglerContainer.mouse_entered.connect(ContainerSelect.bind(true))
	togglerContainer.mouse_exited.connect(ContainerSelect.bind(false))
	toggleGizmos = togglerContainer.get_node("Gizmos")
	for gizmo in gizmos:
		var button = Button.new()
		button.name = gizmo
		button.custom_minimum_size = Vector2(32,32)
		
		button.pressed.connect(ToggleGizmo.bind(gizmo))
		var icon
		if not get_editor_interface().get_base_control().has_theme_icon(gizmo, "EditorIcons"):
			icon = get_editor_interface().get_base_control().get_theme_icon(gizmoIcons.get(gizmo, "Node"), "EditorIcons")
		else:
			icon = get_editor_interface().get_base_control().get_theme_icon(gizmo, "EditorIcons")
		button.icon = icon
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.tooltip_text = "Toggle gizmos: " + gizmo
		button.mouse_filter = Control.MOUSE_FILTER_PASS
		toggleGizmos.add_child(button)
	
	toggleVarious = togglerContainer.get_node("Various")
	var buttonLight = toggleVarious.get_node("Light")
	buttonLight.icon = get_editor_interface().get_base_control().get_theme_icon("GizmoLight", "EditorIcons")
	buttonLight.expand_icon = true
	buttonLight.pressed.connect(ToggleUnshaded.bind())
	var buttonHalfRes = toggleVarious.get_node("Half")
	buttonHalfRes.icon = get_editor_interface().get_base_control().get_theme_icon("BitMap", "EditorIcons")
	buttonHalfRes.pressed.connect(ToggleVarious.bind("Half Resolution"))
	var buttonGizmos = toggleVarious.get_node("Gizmos")
	buttonGizmos.icon = get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")
	buttonGizmos.pressed.connect(ToggleVarious.bind("View Gizmos"))
	
	pass

func _exit_tree():
	togglerContainer.queue_free()
	
	pass

func FindByName(node: Node, nodeName : String, result : Array) -> void:
	if node.name == nodeName:
		result.push_back(node)
	for child in node.get_children(true):
		FindByName(child, nodeName, result)

func FindByClass(node: Node, className : String, result : Array) -> void:
	if node.is_class(className):
		result.push_back(node)
	for child in node.get_children(true):
		FindByClass(child, className, result)

func ContainerSelect(b):
	if b == true:
		togglerContainer.modulate.a = 1
	else:
		togglerContainer.modulate.a = 0.25

func ToggleGizmo(gizmo : String):
	var id = -1
	for item in range(GizmosMenu.item_count):
		if GizmosMenu.get_item_text(item) == gizmo:
			id = GizmosMenu.get_item_id(item)
			break
	
	if id == -1:
		print("[Viewport Toggler] Gizmo not found: " + gizmo)
		return
	
	GizmosMenu.emit_signal("id_pressed", id)
	
func ToggleVarious(gizmo : String):
	var id = -1
	for item in range(VariousMenu.item_count):
		if VariousMenu.get_item_text(item) == gizmo:
			id = VariousMenu.get_item_id(item)
			break

	VariousMenu.emit_signal("id_pressed", id)

func ToggleUnshaded():
	var idU = -1
	var idN = -1
	var idxU = -1
	var idxN = -1
	for item in range(VariousMenu.item_count):
		if VariousMenu.get_item_text(item) == "Display Unshaded":
			idxU = item
			idU = VariousMenu.get_item_id(item)
		if VariousMenu.get_item_text(item) == "Display Normal":
			idxN = item
			idN = VariousMenu.get_item_id(item)
	
	if VariousMenu.is_item_checked(idxU):
		VariousMenu.set_item_checked(idxN, true)
		VariousMenu.set_item_checked(idxU, false)
		VariousMenu.emit_signal("id_pressed", idN)
	else:
		VariousMenu.set_item_checked(idxU, true)
		VariousMenu.set_item_checked(idxN, false)
		VariousMenu.emit_signal("id_pressed", idU)
