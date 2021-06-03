package obj;

class GridObject extends h2d.Graphics {
	/*** the standard grid size, of the base game grid */
	private var size : Int = settings.Grid.SIZE;

	private var outlineColor : Int = 0xFF00FF;
	private var outlineSize : Int = 0;
	private var outlineOpacity : Float = 1;

	private var fillColor : Int = 0xFFFFFF;
	private var fillOpactiy : Float = 1;

	public var gx : Int;
	public var gy : Int;

	public function new(?parent : h2d.Object) {
		super(parent);
		
		updateGraphics();
	}

	private function updateGraphics() {
		clear();

		beginFill();
		if (outlineSize > 0) {
			setColor(outlineColor);
			drawRect(-size/2, -size/2, size, size);
		}
		setColor(fillColor);
		drawRect(-size/2 + outlineSize, -size/2 + outlineSize, size - 2*outlineSize, size - 2*outlineSize);
		endFill();
	}

	public function setGridPosition(position : structures.GridPosition) {
		x = position.cx;
		y = position.cy;
		gx = position.gx;
		gy = position.gy;
	}

	public function collides(objects : Array<Dynamic>) : Bool {
		for (o in objects) if (o.gx == gx && o.gy == gy) return true;
		return false;
	}

	// public function tick() : Bool { return true; }
	public function getColor() : Int return fillColor;
	public function getOutlineColor() : Int return outlineColor;
}