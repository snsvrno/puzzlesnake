package obj;

class GridObject extends h2d.Graphics {
	/*** the standard grid size, of the base game grid */
	inline static public var SIZE : Int = 16;

	private var size : Int = SIZE;

	private var outlineColor : Int = 0xFF00FF;
	private var outlineSize : Int = 0;
	private var outlineOpacity : Float = 1;

	private var fillColor : Int = 0xFFFFFF;
	private var fillOpactiy : Float = 1;

	public var gx(default, null) : Int;
	public var gy(default, null) : Int;

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

	public function setGridPosition(newGx : Int, newGy : Int) : Bool {
		gx = newGx;
		gy = newGy;

		if (Settings.WORLDWRAP) {

			// check if we need to wrap.
			if (gx < 0) gx += Game.instance.width;
			else if (gx >= Game.instance.width) gx -= Game.instance.width;

			if (gy < 0) gy += Game.instance.height;
			else if (gy >= Game.instance.height) gy -= Game.instance.height;

		} else {

			// if we don't world wrap then when we go to the edge of the world
			// its game over.

			// check if have grid points that are outside the board.
			if (gx < 0 || gx >= Game.instance.width || gy < 0 || gy >= Game.instance.height) return false;
		}

		var tile = Game.instance.grid[gx][gy];
		
		x = tile.x;
		y = tile.y;

		return true;
	}

	/**
	 * Sets a random position on the board.
	 *  
	 * @param padding how many grids from the edge to not use (are not valid)
	 * @param blockers grid objects that cannot be spawned inside of.
	 */
	public function setGridPositionRandom(?padding : Int = 0, ?blockers : Array<Array<Dynamic>>) {

		var rx = Math.floor(padding + Math.random() * (Game.instance.width - 2 * padding - 1));
		var ry = Math.floor(padding + Math.random() * (Game.instance.height - 2 * padding - 1));

		var valid = true;
		if (blockers != null) {
			for (bset in blockers) for (b in bset) {
				var gridobject = cast(b, GridObject);
				if (rx == gridobject.gx && ry == gridobject.gy) valid = false;
			}
		}

		if (valid) setGridPosition(rx, ry);
		else setGridPositionRandom(padding, blockers);
	}

	public function collides(objects : Array<Dynamic>) : Bool {
		for (o in objects) if (o.gx == gx && o.gy == gy) return true;
		return false;
	}

	public function tick() : Bool { return true; }
	public function getColor() : Int return fillColor;
}