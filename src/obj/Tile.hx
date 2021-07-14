package obj;

class Tile extends h2d.Graphics {

	private var blockings : Map<Player.Direction, Int> = [];

	public function new(parent : h2d.Object) {
		super(parent);

		updateGraphics();
	}

	public function forceRedraw() {
		updateGraphics();
	}

	private function updateGraphics() {
		clear();
		
		lineStyle(settings.Grid.LINESIZE, Settings.ui2Color, settings.Grid.OPACITY);
		drawRect(-settings.Grid.SIZE/2,-settings.Grid.SIZE/2,settings.Grid.SIZE,settings.Grid.SIZE);

		for (direction => variant in blockings) {
			var color = Settings.getFoodColor(variant);
			lineStyle(settings.Grid.LINESIZE, color, 1);
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

	public function clearBlocking(?direction : Player.Direction) {
		var cleared : Bool = false;

		if (direction != null) cleared = blockings.remove(direction);
		else {
			for (d in blockings.keys()) if (blockings.remove(d) && !cleared) cleared = true;
		}
		
		if (cleared) updateGraphics();
	}

	public function setBlocking(direction : Player.Direction, variant : Int) {
		if (blockings.get(direction) == null) blockings.set(direction, variant);
		updateGraphics();
	}
}