extends Node2D

var handler;
var ship;


# Called when the node enters the scene tree for the first time.
func _ready():
	handler = get_node("Generic_Ship_Handler");
	ship = handler.GetShip();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handler.SetInputsPlayer(Input.is_action_pressed("direction_forward"), Input.is_action_pressed("direction_left"), Input.is_action_pressed("direction_right"), Input.is_action_pressed("direction_back"));
	
	var mousePos = get_global_mouse_position();
	var windowSize = OS.get_window_size();
	$Camera2D.global_position = ship.global_position;
	$Camera2D.offset_h = (mousePos.x - ship.global_position.x) / (windowSize.x / 2.0);
	$Camera2D.offset_v = (mousePos.y - ship.global_position.y) / (windowSize.y / 2.0);
