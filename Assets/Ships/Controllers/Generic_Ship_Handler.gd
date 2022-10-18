extends Node2D

export(PackedScene) var defaultShip;
export(PackedScene) var trailEffect;

var velocity = Vector2.ZERO;
var rotSpeed = 0;
var inpThrust = false; var inpRotateCW = false; var inpRotateCCW = false;
var inpRotateHalt = false; var inpAntiThrust = false; var inpStop = false;
var ship;


func _ready():
	if (len(self.get_children()) == 0):
		pass;
	ship = self.get_children()[0];



func _process(delta):
	var speed = velocity.length();
	
	var rawLinAcc = ship.ship_base_acc / ship.ship_base_mass;
	var rawRotAcc = ship.ship_base_rot_acc / ship.ship_base_mass;
	var rawRCSAcc = ship.ship_base_rcs / ship.ship_base_mass;
	
	var linAcc = rawLinAcc * delta;
	var rotAcc = rawRotAcc * delta;
	var RCSAcc = rawRCSAcc * delta;
	
	# Effect Trackers
	var isThrusting = false;
	var isRCSForward = false;
	var isRCSBackward = false;
	var isRCSLeft = false;
	var isRCSRight = false;
	var isRCSCW = false;
	var isRCSCCW = false;
	
	# Rotation Handling
	if (inpAntiThrust && (speed > rawRCSAcc * 0.5)):
		var diff = fposmod(rotation - velocity.angle(), PI * 2) - PI;
		var rotDist = -diff;
		var stopDist = pow(rotSpeed, 2) / (2 * rawRotAcc);
		if (((rotDist > 0) && (rotSpeed == 0))		# We aren't rotating already
			|| (sign(rotDist) != sign(rotSpeed))	# We are rotating the wrong way
			|| (abs(rotDist) > abs(stopDist))):		# We can accelerate before stopping
			rotSpeed = clamp(rotSpeed + rotAcc * sign(rotDist), -ship.ship_base_rot, ship.ship_base_rot);
			isRCSCW = rotDist >= rotAcc;
			isRCSCCW = rotDist <= -rotAcc;
		else:
			if (abs(rotSpeed) <= rotAcc):
				rotSpeed = 0;
			else:
				rotSpeed = clamp(rotSpeed - rotAcc * sign(rotDist), -ship.ship_base_rot, ship.ship_base_rot);
				isRCSCCW = rotDist >= rotAcc;
				isRCSCW = rotDist <= -rotAcc;
		
		
	elif (inpRotateHalt || inpAntiThrust):
		# Stop rotating
		if (abs(rotSpeed) <= rotAcc):
			rotSpeed = 0;
		else:
			rotSpeed -= rotAcc * sign(rotSpeed);
			isRCSCW = rotSpeed < 0;
			isRCSCCW = rotSpeed > 0;
	elif (inpRotateCW):
		#	Positive Rotation
		if (rotSpeed < ship.ship_base_rot):
			rotSpeed = min(rotSpeed + rotAcc, ship.ship_base_rot);
			isRCSCW = true;
	elif (inpRotateCCW):
		#	Negative Rotation
		if (rotSpeed > -ship.ship_base_rot):
			rotSpeed = max(rotSpeed - rotAcc, -ship.ship_base_rot);
			isRCSCCW = true;
	else:
		# Stop rotating
		if (abs(rotSpeed) <= rotAcc * 0.2):
			rotSpeed = 0;
		else:
			rotSpeed -= rotAcc * 0.2 * sign(rotSpeed);
		
		
	# Thrust Handling
	if (inpAntiThrust && (speed > rawRCSAcc * 0.5)):
		var diff = fposmod(rotation - velocity.angle(), PI * 2) - PI;
		if (abs(diff) < PI / 50):
			velocity += Vector2.RIGHT.rotated(rotation) * linAcc;
			isThrusting = true;
	elif (inpStop || inpAntiThrust):
		if (speed >= RCSAcc * 2):
			var stopDir = -velocity.normalized();
			velocity += stopDir * RCSAcc;
			var locStopDir = stopDir.rotated(-rotation);
			isRCSForward = locStopDir.x >= RCSAcc;
			isRCSBackward = locStopDir.x <= -RCSAcc;
			isRCSRight = locStopDir.y >= RCSAcc;
			isRCSLeft = locStopDir.y <= -RCSAcc;
		else:
			velocity = Vector2.ZERO;
	elif (inpThrust):
		velocity += Vector2.RIGHT.rotated(rotation) * linAcc;
		isThrusting = true;
		if (velocity.length() > ship.ship_base_speed):
			velocity *= ship.ship_base_speed / velocity.length();
	
	rotation += rotSpeed * delta;
	position += velocity * delta;
	
	#	Update effects
	var thrustRoot = ship.get_node("Thrusters");
	var rcsRoot = ship.get_node("RCS");
	
	
	if (isThrusting):
		for thrustNode in thrustRoot.get_children():
			if (thrustNode.activeTrail == null):
				var trail = trailEffect.instance();
				thrustNode.add_child(trail);
				thrustNode.activeTrail = trail;
			thrustNode.activeTrail.AddPoint(thrustNode.global_position - velocity / 60, velocity + Vector2.RIGHT.rotated(thrustNode.global_rotation) * 150);
	else:
		#	Release trails
		for thrustNode in thrustRoot.get_children():
			if (thrustNode.activeTrail != null):
				thrustNode.activeTrail.released = true;
				thrustNode.activeTrail = null;
	
	for rcsNode in rcsRoot.get_children():
		rcsNode.emitting = (
			(rcsNode.isForward && isRCSForward) || (rcsNode.isBackward && isRCSBackward) ||
			(rcsNode.isLeft && isRCSLeft) || (rcsNode.isRight && isRCSRight) ||
			(rcsNode.isCW && isRCSCW) || (rcsNode.isCCW && isRCSCCW));



func GetShip():
	return ship;


func SetInputs(thrust, rotateCW, rotateCCW, rotateHalt, antithrust, stop):
	inpThrust = thrust;
	inpRotateCW = rotateCW;
	inpRotateCCW = rotateCCW;
	inpRotateHalt = rotateHalt;
	inpAntiThrust = antithrust;
	inpStop = stop;
	

func SetInputsPlayer(forward, left, right, back):
	inpThrust = forward && !back;
	inpRotateCW = right && !left;
	inpRotateCCW = left && !right;
	inpRotateHalt = left && right;
	inpAntiThrust = forward && back;
	inpStop = back && !forward;
