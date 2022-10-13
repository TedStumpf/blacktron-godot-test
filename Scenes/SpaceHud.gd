extends CanvasLayer

export (NodePath) var speedometer;
var speedometerMat;

func _ready():
	speedometerMat = get_node(speedometer).get_material();

func SetSpeedometer(speedPerc, rotationPerc):
	if (speedometerMat != null):
		speedometerMat.set_shader_param("speedFullness", speedPerc);
		speedometerMat.set_shader_param("rotationFullness", rotationPerc);
	else:
		print("No Speedometer!");
