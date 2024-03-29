# ******************************************************************************
# coding_area_interface.gd
# ******************************************************************************
#                             This file is part of
#                      RESEARCH CAPSTONE PROJECT - VBlox
# ******************************************************************************
# Copyright (c) 2023-present 12 ESTEMC-3 GROUP 6
# Aicelle Claro
# Shannja Ashley Malelang
# Monique Marcos
# Nica Shane Mijares
# Precious Nina Sarol
# ******************************************************************************
# MIT License
# Copyright (c) 2023 12 ESTEMC-3 GROUP 6
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS," WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# ******************************************************************************

extends Control

# Coding Manager location.
@onready var _coding_block_object: Node2D = get_node("/root/coding_area/coding_block_objects")

# Main menu scene file location.
const _MAIN_MENU_SCN_FILE: String = "res://assets/scenes/main_menu/main_menu.tscn"

# Coding Area backgrounds (For theme).
var _light_mode_bg: Resource = load("res://assets/textures/coding_area_textures/editor/background_white.png")
var _dark_mode_bg: Resource = load("res://assets/textures/coding_area_textures/editor/background_dark.png")
var _light_mode_logo: Resource = load("res://assets/dev/vblox_logo/logo_flat_white.png")
var _dark_mode_logo: Resource = load("res://assets/dev/vblox_logo/logo_flat_gray.png")

# Pause menu interface nodes.
@onready var _pause_menu: Control = get_node("pause_menu")
@onready var _pause_menu_background: ColorRect = get_node("pause_menu/background")
@onready var _pause_menu_btn: Button = get_node("pause_menu/menu_button")

# Blocks menu interface nodes.
#@onready var _blocks_menu: Control = get_node("blocks_menu")
@onready var _blocks_menu_background: Panel = get_node("blocks_menu/blocks_panel")
@onready var _blocks_span_btn: TextureButton = get_node("blocks_menu/blocks_panel/span_blocks_panel")
@onready var _blocks_separator: VBoxContainer = get_node("blocks_menu/blocks_panel/blocks_container/blocks_separator")

# Labels for block groups.
@onready var _label_events: Label = get_node("blocks_menu/blocks_panel/blocks_container/blocks_separator/events_separator")
@onready var _label_variables: Label = get_node("blocks_menu/blocks_panel/blocks_container/blocks_separator/variables_separator")

# Compiler panel.
@onready var _compile_panel: Control = get_node("blocks_menu/compile_panel")
@onready var _compile_panel_background: Panel = get_node("blocks_menu/compile_panel/compile_panel_background")
@onready var _compile_button_panel: Panel = get_node("blocks_menu/compile_panel/button_panel")
@onready var _compile_text_message: Label = get_node("blocks_menu/compile_panel/compile_panel_background/output_panel/output_text")

# ******************************************************************************
# VARIABLE TUTORIAL | EDITOR INTRO & VARIABLES
@onready var _tut_manager: Control = get_node("tutorial")

@onready var _vtut_1: Polygon2D = get_node("tutorial/tutorial_open_panel")
@onready var _vtut_2: Polygon2D = get_node("tutorial/tutorial_block_menu")
@onready var _vtut_3: Polygon2D = get_node("tutorial/tutorial_add_block")
@onready var _vtut_4: Polygon2D = get_node("tutorial/tutorial_event_block")
@onready var _vtut_5: Polygon2D = get_node("tutorial/tutorial_compiler")
@onready var _vtut_6: Polygon2D = get_node("tutorial/tutorial_comp_screen")
@onready var _vtut_7: Polygon2D = get_node("tutorial/tutorial_editor_controls")
@onready var _vtut_8: Polygon2D = get_node("tutorial/tutorial_add_set_var_block")
@onready var _vtut_9: Polygon2D = get_node("tutorial/tutorial_edit_set_var")
@onready var _vtut_10: Polygon2D = get_node("tutorial/tutorial_screen_var")
@onready var _vtut_11: Polygon2D = get_node("tutorial/tutorial_add_disp_block")
@onready var _vtut_12: Polygon2D = get_node("tutorial/tutorial_edit_disp")
@onready var _vtut_13: Polygon2D = get_node("tutorial/tutorial_change_var")
@onready var _vtut_14: Polygon2D = get_node("tutorial/tutorial_outro")

var _vtut_counter: int = 1

var _vtut_progress = {}

# ******************************************************************************

# Default Constants for UI.
const _POS_DURATION: float = 0.5

# Pause manager.
var _is_paused: bool = false

# Selected Block will queued for deletion.
var _can_delete_block: bool = false

# ******************************************************************************
# INITIATION
# Initiate logic.
func _ready() -> void:
	# Setting the theme and animating the panel for splash.
	_apply_theme()
	
	# Format the disabled buttons automatically.
	_disable_block_buttons(_blocks_separator)
	
	# Animate themes.
	_animate_compiler_panel(false)
	_animate_blocks_menu(false)
	
	# Start Tutorial.
	_create_tut_progress()
	_progress_tutorial(1)

# ******************************************************************************
# INPUT EVENTS
func _input(_event) -> void:
	if _event is InputEventKey:
		if _event.keycode == Configuration.interface_keys.values()[0] and _event.pressed:
			_animate_pause_menu()
			_manage_pause()
		
		# For tutorials.
		elif _event.keycode == Configuration.interface_keys.values()[1] and _event.pressed:
			_handle_mb_tut()
	
	elif _event is InputEventMouseButton:
		if _can_delete_block and CompilerEngine.get_interactor().get_interacted_block():
			if not _event.pressed:
				CompilerEngine.remove_coding_block(CompilerEngine.get_interactor().get_interacted_block(), _coding_block_object)

# ******************************************************************************
# PHYSICS
func _physics_process(_delta):
	_display_compiler_message()

# ******************************************************************************
# CUSTOM METHODS AND SIGNALS
# Change theme logic.
func _apply_theme() -> void:
	# Set theme on background interfaces.
	_pause_menu_background.color = Configuration.user_themes.values()[Configuration.current_theme][0]
	_pause_menu_background.color.a = 0
	
	var _blocks_menu_panel: StyleBoxFlat = _blocks_menu_background.get_theme_stylebox("panel")
	_blocks_menu_panel.bg_color = Configuration.user_themes.values()[Configuration.current_theme][0]
	_blocks_menu_panel.bg_color.a = 0.39
	_blocks_menu_background.add_theme_stylebox_override("panel", _blocks_menu_panel)
	
	# Adjust panel with the proper corners.
	_blocks_menu_panel.corner_radius_top_left = 30
	_blocks_menu_panel.corner_radius_top_right = 30
	_blocks_menu_panel.corner_radius_bottom_left = 0
	_blocks_menu_panel.corner_radius_bottom_right = 0
	_compile_panel_background.add_theme_stylebox_override("panel", _blocks_menu_panel)
	_compile_button_panel.add_theme_stylebox_override("panel", _blocks_menu_panel)
	
	# Set Coding Area Background
	set_coding_area_background(Configuration.current_theme)
	
	# Set Labels with the theme.
	_label_events.add_theme_color_override("font_color", Configuration.user_themes.values()[Configuration.current_theme][6])
	_label_variables.add_theme_color_override("font_color", Configuration.user_themes.values()[Configuration.current_theme][6])

# Manage pause of tree.
func _manage_pause(_paused: bool = _is_paused) -> void:
	get_tree().paused = _paused
	_is_paused = _paused

# Animate pause menu.
func _animate_pause_menu() -> void:
	# Creating tween managers.
	var _anim_bg_opacity: Tween = create_tween()
	var _anim_menu_opacity: Tween = create_tween()
	var _anim_menu_pos: Tween = create_tween()
	
	# Create parameters for tween.
	var _final_color: float
	var _final_pos: Vector2 = Vector2.ZERO
	const _COLOR_DURATION: float = 0.25
	
	# When interface is paused, tween the menu.
	if not _is_paused:
		_is_paused = true
		_final_color = 0.75
		_final_pos = Vector2.ZERO
		
		# Resets the position and modulate so that the tween can be played.
		_pause_menu.position = Vector2(0, 50)
	else:
		_is_paused = false
		_final_color = 0
		_final_pos = Vector2(0, 50)
		
		_pause_menu.position = Vector2(0, 0)
	
	# Play tween animations.
	_anim_bg_opacity.tween_property(_pause_menu_background, "color:a", _final_color,  _COLOR_DURATION).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	_anim_menu_opacity.tween_property(_pause_menu, "modulate:a", _final_color,  _COLOR_DURATION * 1.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	_anim_menu_pos.tween_property(_pause_menu, "position", _final_pos, _POS_DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

# Animate blocks menu
func _animate_blocks_menu(_span: bool) -> void:
	# Creating tween managers.
	var _anim_menu_pos: Tween = create_tween()
	
	# Create parameters for tween.
	var _final_pos: Vector2 = Vector2.ZERO
	
	# When span is enabled, tween the menu.
	if _span:
		_final_pos = Vector2.ZERO
	else:
		_final_pos = Vector2(-(_blocks_menu_background.get_size().x - _blocks_span_btn.get_size().x) , 0)
	
	# Play tween animations.
	_anim_menu_pos.tween_property(_blocks_menu_background, "position", _final_pos, _POS_DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

# Animate compiler panel.
func _animate_compiler_panel(_span: bool):
	# Creating tween managers.
	var _anim_menu_pos: Tween = create_tween()
	
	# Create parameters for tween.
	var _final_pos: Vector2 = _compile_panel.global_position
	
	# When span is enabled, tween the menu.
	if _span:
		_final_pos = Vector2(_compile_panel.global_position.x, (_compile_panel.get_size().y - _compile_button_panel.get_size().y))
	else:
		_final_pos = Vector2(_compile_panel.global_position.x, (_compile_panel.global_position.y - _compile_button_panel.get_size().y) + (_compile_panel.get_size().y - _compile_button_panel.get_size().y))
	
	# Play tween animations.
	_anim_menu_pos.tween_property(_compile_panel, "position", _final_pos, _POS_DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

# Signal from button to go to menu.
func _on_menu_button_pressed() -> void:
	# Change the button to "Loading..." for user experience.
	_pause_menu_btn.disabled = true
	_pause_menu_btn.text = "Loading..."
	
	# Toggles pause of tree.
	_manage_pause(false)
	
	# Creates a timer for 3s so to make sure the player know that its "changing the scene".
	await get_tree().create_timer(Configuration.LOADING_TIME).timeout
	
	# Change the scene.
	get_tree().change_scene_to_file(_MAIN_MENU_SCN_FILE)

# Signal from button to span the menu.
func _on_span_blocks_panel_toggled(_button_pressed: bool) -> void:
	_animate_blocks_menu(not _button_pressed)
	
	# For tutorial.
	if _vtut_counter == 1:
		_progress_tutorial(2)
		
		# Continue.
		if Input.is_action_just_pressed("MOUSE_BUTTON_LEFT"):
			_progress_tutorial(3)

# ******************************************************************************
# Communicate to the Coding Compiler on what block to add.

# DISPLAY
func _on_display_visual_pressed():
	CompilerEngine.add_coding_block("DISPLAY_display_value", _coding_block_object)
	
	# For tutorial.
	if _vtut_counter == 11:
		_progress_tutorial(12)

# EVENTS
func _on_when_play_pressed_pressed():
	CompilerEngine.add_coding_block("EVENT_when_play_pressed", _coding_block_object)
	
	# For tutorial.
	if _vtut_counter == 3:
		_progress_tutorial(4)

# VARIABLES
func _on_set_variable_pressed():
	CompilerEngine.add_coding_block("VARIABLE_set_variable", _coding_block_object)
	
	# For tutorial.
	if _vtut_counter == 8:
		_progress_tutorial(9)

func _on_change_variable_pressed():
	CompilerEngine.add_coding_block("VARIABLE_change_variable", _coding_block_object)
	
	# For tutorial.
	if _vtut_counter == 13:
		_progress_tutorial(14)

# ******************************************************************************
# Remove current block.
func _on_blocks_panel_mouse_entered():
	_can_delete_block = CompilerEngine.queued_block_for_deletion(true)

func _on_blocks_panel_mouse_exited():
	if _is_mouse_outside_block_menu_bounds():
		_can_delete_block = CompilerEngine.queued_block_for_deletion(false)

# ******************************************************************************
# Compiler Panel.
func _on_compile_btn_pressed():
	if not CompilerEngine.compiler_enabled:
		_animate_compiler_panel(true)
		CompilerEngine.enable_compiler(true, _coding_block_object)
	
	# For tutorial.
	if _vtut_counter == 5:
		_progress_tutorial(6)
	
	elif _vtut_counter == -1:
		_progress_tutorial(10)
	
	elif _vtut_counter == -2:
		_progress_tutorial(13)

func _on_stop_compile_btn_pressed():
	if CompilerEngine.compiler_enabled:
		_animate_compiler_panel(false)
		CompilerEngine.enable_compiler(false, null)
	
	# For tutorial.
	if _vtut_counter == 6:
		_progress_tutorial(7)
	
	elif _vtut_counter == 10:
		_progress_tutorial(11)

# ******************************************************************************
# TOOLS
# Set background of coding area. Dirty way to do this.
func set_coding_area_background(_bg: int):
	if _bg == 1:
		get_node("/root/coding_area/background").set_texture(_dark_mode_bg)
		get_node("/root/coding_area/background/logo").set_texture(_dark_mode_logo)
	elif _bg == 2:
		get_node("/root/coding_area/background").set_texture(_light_mode_bg)
		get_node("/root/coding_area/background/logo").set_texture(_light_mode_logo)

# Some weird code because apparently from reddit that, if you entered a control node inside the panel,
# it will fire exit signal. So this is put in order to make sure it will leave the area as whole 
# to fire the signal.
func _is_mouse_outside_block_menu_bounds() -> bool:
	var _output: bool = false
	if not Rect2(Vector2(0, 0), _blocks_menu_background.size).has_point(get_local_mouse_position()):
		_output = true
	return _output

# ******************************************************************************
# Tools.
# Disables the buttons.
func _disable_block_buttons(_task_separator: VBoxContainer) -> void:
	var _idx: int = 0
	for _task in _task_separator.get_children():
		_idx += 1
		# Index distance of start to the preferred value.
		# 7 because the others are not unlocked yet.
		# Bad dev.
		if _idx > 7:
			if _task is TextureButton:
				_task.disabled = true
				_task.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
			_task.modulate = Color.html("ffffff38")

# Display compiler messages.
func _display_compiler_message() -> void:
	# Checks if compiler is enabled.
	if CompilerEngine.compiler_enabled:
		_compile_text_message.text = "Compiler is on...but nothing is happening."
		# Used so that it will not spam empty lines.
		if CompilerEngine.compiler_message != null:
			_compile_text_message.text = CompilerEngine.compiler_message
	else:
		_compile_text_message.text = "Compiler is off..."

# ******************************************************************************
# Tutorial.
# Skip.
func _on_skip_tut_btn_pressed() -> void:
	_progress_tutorial(0)

func _create_tut_progress() -> void:
	# Updates the progress.
	_vtut_progress = {
		1: _vtut_1,
		2: _vtut_2,
		3: _vtut_3,
		4: _vtut_4,
		5: _vtut_5,
		6: _vtut_6,
		7: _vtut_7,
		8: _vtut_8,
		9: _vtut_9,
		10: _vtut_10,
		11: _vtut_11,
		12: _vtut_12,
		13: _vtut_13,
		14: _vtut_14
	}

# Handle mouse button events on tutorials.
func _handle_mb_tut() -> void:
	# Continue when mouse pressed.
	if _vtut_counter == 2:
		_progress_tutorial(3)
	
	elif _vtut_counter == 4:
		_progress_tutorial(5)
	
	elif _vtut_counter == 7:
		_progress_tutorial(8)
	
	elif _vtut_counter == 9:
		# -1 because it will wait for an action to occur. Increment to negative if persists.
		# 0 will be used if no more tutorials.
		_progress_tutorial(-1)
	
	elif _vtut_counter == 12:
		_progress_tutorial(-2)
	
	elif _vtut_counter == 14:
		_progress_tutorial(0)

# Adjusts the visibility of states, depending on the progress.
func _progress_tutorial(_curr_phase: int) -> void:
	# Updates the phase.
	_vtut_counter = _curr_phase
	
	# Sets the visibility of phases.
	if _vtut_progress.has(_vtut_counter):
		for _phase in _vtut_progress.keys():
			_vtut_progress.values()[_phase - 1].set_visible(_phase == _vtut_counter)
	else:
		# If visibility has been set to 0, meaning no more tutorial phase.
		if _vtut_counter == 0:
			_tut_manager.set_visible(false)
		else:
			for _phase in _vtut_progress.keys():
				_vtut_progress.values()[_phase - 1].set_visible(false)


