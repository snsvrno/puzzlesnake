package game;

import obj.GridObject;

class Grid extends h2d.Object {

	/*** the width of a grid cell in pixels.*/
	public final cellWidth : Int;
	/*** the width of a grid cell in pixels.*/
	public final cellHeight : Int;

	/*** the number of cells in the width.*/
	public final width : Int;
	/*** the number of cells in the height.*/
	public final height : Int;

	public var pixelWidth(get, never) : Int;
	private function get_pixelWidth() : Int return width * cellWidth;
	public var pixelHeight(get, never) : Int;
	private function get_pixelHeight() : Int return height * cellHeight;

	private var cells : Array<Array<obj.Tile>>;

	public function new(width : Int, height : Int, parent : h2d.Object) {
		super(parent);

		this.width = width;
		this.height = height;

		cellWidth = 10;
		cellHeight = 10;

		init();
	}

	/**
	 * builds the grid array structure.
	 */
	private function init() {
		cells = [];
		for (i in 0 ... width) {
			var column = new Array<obj.Tile>();
			for (j in 0 ... height) {
				var tile = new obj.Tile(this);
				tile.x = i * obj.Tile.SIZE + obj.Tile.SIZE/2;
				tile.y = j * obj.Tile.SIZE + obj.Tile.SIZE/2;
				column.push(tile);
			}
			cells.push(column);
		}
	}

	/**
	 * call back function becauuse i don't know how to
	 * make an iterator right now.
	 * @param callback 
	 * @return -> Void)
	 */
	public function foreach(callback : (t : obj.Tile) -> Void) {
		
		for (i in 0 ... width) {
			for (j in 0 ... height) {
				callback(cells[i][j]);
			}
		}
	}

	public function getTile(gx : Int, gy : Int) : Null<obj.Tile> {
		if (gx < 0 || gx > width-1 || gy < 0 || gy > height - 1) return null;
		else return cells[gx][gy];
	}

	public function getRandomPosition(?padding : Int = 0, ?blockers : Array<Array<Dynamic>>) : structures.GridPosition {
		
		var rx = Math.floor(padding + Math.random() * (width - 2 * padding - 1));
		var ry = Math.floor(padding + Math.random() * (height - 2 * padding - 1));

		var valid = true;
		if (blockers != null) {
			for (bset in blockers) for (b in bset) {
				var gridobject = cast(b, GridObject);
				if (rx == gridobject.gx && ry == gridobject.gy) valid = false;
			}
		}

		if (valid) { 
			var tile = cells[rx][ry];
			return { gx : rx, gy : ry, cx : tile.x, cy : tile.y };
		} else return getRandomPosition(padding, blockers);

	}

	public function getScreenPosition(gx : Int, gy : Int) : Null<structures.GridPosition> {

		if (Settings.WORLDWRAP) {

			// check if we need to wrap.
			if (gx < 0) gx += width;
			else if (gx >= width) gx -= width;

			if (gy < 0) gy += height;
			else if (gy >= height) gy -= height;

		} else {

			// if we don't world wrap then when we go to the edge of the world
			// its game over.

			// check if have grid points that are outside the board.
			if (gx < 0 || gx >= width || gy < 0 || gy >= height) return null;
		}

		var tile = getTile(gx,gy);
		// we should't have a null at this point because of the above checks, but
		// maybe we still do?
		if (tile == null) return null;
		
		return {
			gx : gx, gy : gy,
			cx : tile.x,
			cy : tile.y,
		};

	}

	public function isEdge(gx : Int, gy : Int) : Bool {
		return gx == 0 || gy == 0 || gx == width || gy == height;
	}
}