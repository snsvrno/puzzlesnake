package obj;

class GridObject extends h2d.Graphics {

	/*** a master list of objects so that we can update them per tick */
	static private var objects : Array<GridObject> = [];
	static public function runAllTicks() for (o in objects) o.turnTick();
	static public function runAppUpdates(dt : Float) for (o in objects) o.update(dt);

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
		// adds this to the master list of objects
		objects.push(this);

		updateGraphics();
	}

	public override function onRemove() {
		super.onRemove();

		// removes this from the master list of objects
		for (o in objects) {
			if (o == this) {
				objects.remove(this);
				return;
			}
		}

	}

	public function update(dt : Float) { }

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

	public function getGridPosition() : structures.GridPosition {
		return { cx : x, cy : y, gx : gx, gy : gy };
	}

	/**
	 * checks if something collides the the given array of objects. an optional callback can
	 * be provided that allows you to check what the collision is and cancel the collision if
	 * desired.
	 * @param objects 
	 * @param callback 
	 * @return -> Bool) : Bool
	 */
	public function collides(objects : Array<Dynamic>, ?callback : (obj : Dynamic) -> Bool) : Bool {
		for (o in objects) { 
			if (o.gx == gx && o.gy == gy) {
				if (callback != null && callback(o) != true) return true;
				else if (callback == null) return true;
			}
		}
		return false;
	}

	/*** called on every turn */
	public function turnTick() { }

	public function getColor() : Int return fillColor;
	public function getOutlineColor() : Int return outlineColor;
}