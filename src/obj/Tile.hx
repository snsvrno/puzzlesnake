package obj;

class Tile extends h2d.Graphics {

	private var blockings : Map<Player.Direction, Int> = [];

	public function new(parent : h2d.Object) {
		super(parent);
		updateGraphics();
	}

	private function updateGraphics() {
		clear();
		
		lineStyle(settings.Grid.LINESIZE, Settings.ui2Color, settings.Grid.OPACITY);
		drawRect(-settings.Grid.SIZE/2,-settings.Grid.SIZE/2,settings.Grid.SIZE,settings.Grid.SIZE);

		for (direction => color in blockings) {
			lineStyle(settings.Grid.LINESIZE, color, Settings.ui2Color);
			switch(direction) {
				case Up: 
					moveTo(-settings.Grid.SIZE/2, -settings.Grid.SIZE/2 + settings.Grid.LINESIZE);
					lineTo(settings.Grid.SIZE/2, -settings.Grid.SIZE/2 + settings.Grid.LINESIZE);

				case Down:
					moveTo(-settings.Grid.SIZE/2, settings.Grid.SIZE/2);
					lineTo(settings.Grid.SIZE/2, settings.Grid.SIZE/2);
					
				case Left:
					moveTo(-settings.Grid.SIZE/2 + settings.Grid.LINESIZE, -settings.Grid.SIZE/2 );
					lineTo(-settings.Grid.SIZE/2 + settings.Grid.LINESIZE, settings.Grid.SIZE/2);

				case Right:
					moveTo(settings.Grid.SIZE/2, -settings.Grid.SIZE/2);
					lineTo(settings.Grid.SIZE/2, settings.Grid.SIZE/2);
			}
		}
	}

	public function clearBlocking() {
		var cleared : Bool = false;
		for (d in blockings.keys()) if (blockings.remove(d) && !cleared) cleared = true;
		if (cleared) updateGraphics();
	}

	public function setBlocking(direction : Player.Direction, color : Int) {
		if (blockings.get(direction) == null) blockings.set(direction, color);
		updateGraphics();
	}
}