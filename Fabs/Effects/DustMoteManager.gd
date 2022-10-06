extends Node2D

export var count := 50;
export var radius := 500;
export var maxSpeed := 300.0;
export(Curve) var speedCurve;
export(PackedScene) var dustEffect;
var ship;


func _ready():
	for i in range(count):
		var mote = dustEffect.instance();
		add_child(mote);
		mote.global_position = global_position + Vector2.RIGHT.rotated(rand_range(0, PI * 2)) * rand_range(0, radius);
		mote.scale = Vector2(0, 0);
		
	
	
func _process(delta):
	if (ship == null):
		ship = get_parent().ship;
		return;
	var offset = ship.global_position - global_position;
	var speed = offset.length();
	var angle = atan2(offset.y, offset.x);
	var speedPerc = (speed / delta) / maxSpeed;
	var speedScale = speedCurve.interpolate(speedPerc);
	
	global_position = ship.global_position;
	for mote in get_children():
		mote.position -= offset;
		mote.rotation = angle;
		mote.scale = Vector2(speedScale, speedScale);
		var distance = mote.position.length();
		if (distance > radius * 1.1):
			ResetPosition(mote);

		
func ResetPosition(mote):
	mote.global_position = global_position + Vector2.RIGHT.rotated(rand_range(0, PI * 2)) * (radius * rand_range(1, 1.1));
