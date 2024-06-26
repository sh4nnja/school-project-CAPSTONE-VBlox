# ******************************************************************************
# set_variable.gd
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

extends CodingBlocks

# Block Data.
var block_type: String = "set_variable"

@onready var block_var_name: LineEdit = get_node("set_variable_texture/set_label/name")
@onready var block_var_value: LineEdit = get_node("set_variable_texture/set_label/name/to_label/value")

# Connections.
@onready var block_head: Area2D = get_node("head")
@onready var block_tail: Area2D = get_node("tail")

var block_connected_head: CodingBlocks
var block_connected_tail: CodingBlocks

# Check what block we are attempting to connect to.
var attaching_connector: Area2D

# Block shape. For dragging.
@onready var _block_texture: NinePatchRect = get_node("set_variable_texture")
@onready var _block_shape: CollisionShape2D = get_node("set_variable_shape")

# Enable dragging.
var dragging_enabled: bool = false

# Check if block can snap.
var can_snap: int = 0

# Location of initial text area size.
var _block_init_text_size: float
var _name_init_area_size: float 
var _value_init_area_size: float

# ******************************************************************************
# INIT EVENT
func _ready() -> void:
	_get_init_text_area()
	_adjust_block()

# INPUT EVENT
func _input(_event) -> void:
	manage_dragging(_event)

# ******************************************************************************
# CUSTOM METHODS AND SIGNALS
# When mouse is inside the coding block (For dragging).
func _on_mouse_entered():
	manage_hover(self, true)

func _on_mouse_exited():
	manage_hover(self, false)
	_remove_focus()

# For snapping and attaching.
func _on_head_area_entered(_area):
	manage_block_snapping(block_head, _area, true)

func _on_head_area_exited(_area):
	manage_block_snapping(block_head, _area, false)

func _on_tail_area_entered(_area):
	manage_block_snapping(block_tail, _area, true)

func _on_tail_area_exited(_area):
	manage_block_snapping(block_tail, _area, false)

# For changing the value and name.
func _on_name_text_changed(_new_text):
	_adjust_block()

func _on_value_text_changed(_new_text):
	_adjust_block()

# ******************************************************************************
# TOOLS
# Update dragging of the block.
# Get the variables' data.
func get_block_data() -> Dictionary:
	return {
		block_var_name: block_var_value 
	}

func update_dragging(draggable: bool) -> void:
	dragging_enabled = draggable
	
	# Update text fields so that it will not be selected when dragging.
	block_var_name.editable = not dragging_enabled
	block_var_value.editable = not dragging_enabled

# Removes focus on all text when mouse is outside the block.
func _remove_focus() -> void:
	block_var_name.release_focus()
	block_var_value.release_focus()

# Get init area size.
func _get_init_text_area() -> void:
	_block_init_text_size = _block_texture.get_size().x
	_name_init_area_size = block_var_name.get_size().x
	_value_init_area_size = block_var_value.get_size().x

# Adjust block's position and size based on text.
func _adjust_block() -> void:
	_block_texture.size.x = _block_init_text_size + manage_block_tex_size((_name_init_area_size + _value_init_area_size), (block_var_name.get_size().x + block_var_value.get_size().x), 0.35)
	_block_shape.position.x = manage_block_shape_size(_block_texture.size.x)
	_block_shape.shape.size.x = manage_block_shape_size(_block_texture.size.x, 4)

