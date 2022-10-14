tool
extends TextureRect

export var randomSeed : int;
export (int, 10000) var starCount := 0;
export var starColors : Gradient;
export var starBrightness : Curve;
export (float) var lineBias := 2.0;


var RNG : RandomNumberGenerator;
var starPos : Array;
var starDataImg : Image;
var starDataTex : ImageTexture;
var myMat : Material;
var lineSlope : float;
var lineOffset : Vector2;

onready var cachedSeed := randomSeed;

func _ready():
	init();

func _process(_delta):
	if (starDataImg == null):
		init();
		return;
		
	if (cachedSeed != randomSeed):
		cachedSeed = randomSeed;
		RegenStars();
		return;
		
	if (starPos.size() != starCount):
		RegenStars();

func init():
	RNG = RandomNumberGenerator.new();
	starPos = []
	starDataTex = self.texture;
	
	starDataImg = Image.new();
	starDataImg.create(1, 1, false, 4);
	Resize(1024, 600);
	RegenStars();

func Resize(w, h):
	if (starDataImg == null):
		init();
	starDataImg.unlock();
	starDataImg.resize(w, h);
	RedrawStars()

func RedrawStars():
	starDataImg.lock();
	starDataImg.fill(Color.black);
	
	for i in min(starCount, starPos.size()):
		starDataImg.lock();
		var col = lerp(Color.black, starColors.interpolate(starPos[i].c), starBrightness.interpolate(starPos[i].b));
		starDataImg.set_pixel(starPos[i].x * starDataImg.get_width(), starPos[i].y * starDataImg.get_height(), col);
	
	starDataTex.create_from_image(starDataImg);

func RegenStars():
	RNG.seed = randomSeed;
	lineSlope = RNG.randf_range(-10, 10);
	lineOffset = 0.1 * Vector2(RNG.randf_range(-1, 1), RNG.randf_range(-1, 1)) + Vector2(0.5, 0.5);
	
	starPos = []
	
	var x1 = lineOffset.x;
	var y1 = lineOffset.y;
	var slopeLen = sqrt(1 + pow(lineSlope, 2));
	
	for i in starCount:
		var b = lineBias;
		var minDist = INF;
		var bestPos;
		
		RNG.seed = randomSeed * 10000 + starPos.size();
		while (b > 0):
			if ((b >= 1) || (b > RNG.randf())):
				var pos = StarData.new();
				pos.Set(RNG.randf(), RNG.randf(), RNG.randf(), RNG.randf());
				var x0 = pos.x;
				var y0 = pos.y;
				var dist = abs((y1 - y0) - (lineSlope * (x1 - x0))) / slopeLen;
				if (dist < minDist):
					bestPos = pos;
					minDist = dist;
				b -= 1;
		starPos.append(bestPos);
	RedrawStars();

func _on_Starfield_item_rect_changed():
	Resize(self.get_size().x, self.get_size().y);

class StarData:
	var x : float;
	var y : float;
	var c : float;
	var b : float;
	
	func Set(sx, sy, sc, sb):
		x = sx;
		y = sy;
		c = sc;
		b = sb;
