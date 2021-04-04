package obj;

class Tile extends h2d.Graphics {

	private var blockings : Map<Player.Direction, Int> = [];

	public function new(parent : h2d.Object) {
		super(parent);
		updateGraphics();
	}

	private function updateGraphics() {
		clear();
		
		lineStyle(Settings.GRIDTHICKNESS, Settings.GRIDCOLOR, Settings.GRIDOPACITY);
		drawRect(-Settings.GRIDSIZE/2,-Settings.GRIDSIZE/2,Settings.GRIDSIZE,Settings.GRIDSIZE);

		for (direction => color in blockings) {
			lineStyle(Settings.GRIDTHICKNESS, color);
			switch(direction) {
				case Up: 
					moveTo(-Settings.GRIDSIZE/2, -Settings.GRIDSIZE/2);
					lineTo(Settings.GRIDSIZE/2, -Settings.GRIDSIZE/2);

				case Down:
					moveTo(-Settings.GRIDSIZE/2, Settings.GRIDSIZE/2);
					lineTo(Settings.GRIDSIZE/2, Settings.GRIDSIZE/2);
					
				case Left:
					moveTo(-Settings.GRIDSIZE/2, -Settings.GRIDSIZE/2);
					lineTo(-Settings.GRIDSIZE/2, Settings.GRIDSIZE/2);

				case Right:
					moveTo(Settings.GRIDSIZE/2, -Settings.GRIDSIZE/2);
					lineTo(Settings.GRIDSIZE/2, Settings.GRIDSIZE/2);
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