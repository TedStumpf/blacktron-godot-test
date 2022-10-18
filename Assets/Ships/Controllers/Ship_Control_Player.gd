extends Node2D

var handler;
var ship;
var HUD;


# Called when the node enters the scene tree for the first time.
func _ready():
	handler = get_node("Generic_Ship_Handler");
	ship = handler.GetShip();
	HUD = get_parent().get_node("HUD");


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	handler.SetInputsPlayer(Input.is_action_pressed("direction_forward"), Input.is_action_pressed("direction_left"), Input.is_action_pressed("direction_right"), Input.is_action_pressed("direction_back"));
	
	HUD.SetSpeedometer(handler.velocity.length() / ship.ship_base_speed, handler.rotSpeed / -ship.ship_base_rot);
	
	var mousePos = get_global_mouse_position();
	var windowSize = OS.get_window_size();
	var velOffsetPos = ship.global_position - (handler.velocity);
	$Camera2D.global_position = ship.global_position;
	$Camera2D.offset_h = (mousePos.x - velOffsetPos.x) / (windowSize.x / 2.0);
	$Camera2D.offset_v = (mousePos.y - velOffsetPos.y) / (windowSize.y / 2.0);
