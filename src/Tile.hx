class Tile extends h2d.Graphics {

	inline static private var COLOR : Int = 0x222222;
	inline static private var OPACITY : Float = 1;
	inline static public var SIZE : Int = 16;
	inline static private var THICKNESS : Int = 1;

	public function new(parent : h2d.Object) {
		super(parent);

		lineStyle(THICKNESS, COLOR, OPACITY);
		drawRect(-SIZE/2,-SIZE/2,SIZE,SIZE);
	}
}