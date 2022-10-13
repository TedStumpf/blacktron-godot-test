extends Line2D

export var length := 250;
export var idealDelta := 0.04;
var updateRate := 0.05;
var tickTime = 0;
var drift := 0.3;
var released = false;
var velocity = []

func _process(delta):
	global_position = Vector2(0, 0);
	global_rotation = 0;
	
	if (get_point_count() > 0):
		#tickTime += delta;
		if (true):#tickTime >= idealDelta):
			tickTime = 0;
			idealDelta = delta;
			for i in range(get_point_count()):
				var wildness = float(i) / length;
				var point = get_point_position(i);
				point += velocity[i] * idealDelta + Vector2(rand_range(-drift, drift), rand_range(-drift, drift)) * wildness;
				set_point_position(i, point);
	
	if (released):
		remove_point(0);
		velocity.pop_front();
		if (get_point_count() == 0):
			hide();
			queue_free();

func AddPoint(point, vel):
	add_point(point);
	velocity.append(vel);
	
	if (get_point_count() > length):
		remove_point(0);
		velocity.pop_front();
