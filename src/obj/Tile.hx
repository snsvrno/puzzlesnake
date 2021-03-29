package obj;

class Tile extends h2d.Graphics {

	inline static private var COLOR : Int = 0x222222;
	inline static private var OPACITY : Float = 1;
	inline static public var SIZE : Int = 16;
	inline static private var THICKNESS : Int = 1;

	private var blockings : Map<Player.Direction, Int> = [];

	public function new(parent : h2d.Object) {
		super(parent);
		updateGraphics();
	}

	private function updateGraphics() {
		clear();
		
		lineStyle(THICKNESS, COLOR, OPACITY);
		drawRect(-SIZE/2,-SIZE/2,SIZE,SIZE);

		for (direction => color in blockings) {
			lineStyle(THICKNESS, color);
			switch(direction) {
				case Up: 
					moveTo(-SIZE/2, -SIZE/2);
					lineTo(SIZE/2, -SIZE/2);

				case Down:
					moveTo(-SIZE/2, SIZE/2);
					lineTo(SIZE/2, SIZE/2);
					
				case Left:
					moveTo(-SIZE/2, -SIZE/2);
					lineTo(-SIZE/2, SIZE/2);

				case Right:
					moveTo(SIZE/2, -SIZE/2);
					lineTo(SIZE/2, SIZE/2);
			}
		}
	}

	public function clearBlocking() {
		for (d in blockings.keys()) blockings.remove(d);
	}

	public function setBlocking(direction : Player.Direction, color : Int) {
		if (blockings.get(direction) == null) blockings.set(direction, color);
		updateGraphics();
	}
}