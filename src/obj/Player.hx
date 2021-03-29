package obj;

enum Direction { Up; Down; Left; Right; }

class Player extends GridObject {
	private var direction : Direction;
	private var movingDirection : Direction;

	private var eyeSize : Int = 2;
	private var eyePadding : Int = 2;
	private var eyeColor : Int = 0xFFFFFF;

	private var lastColor : Int;

	public function new(?parent : h2d.Object) {
		super(parent);

		// settings
		fillColor = Utils.RGBToHex(0,0,255);
		lastColor = Utils.RGBToHex(0,0,150);

		setRandomDirection();

		updateGraphics();
	}

	override function updateGraphics() {
		super.updateGraphics();

		if (direction == null) return;

		beginFill(eyeColor);
		switch(direction) {
			case Up:
				drawRect(-size/2 + eyePadding, -size/2 + eyePadding, eyeSize, eyeSize);
				drawRect(size/2 - eyePadding - eyeSize, -size/2 + eyePadding, eyeSize, eyeSize);

			case Down:
				drawRect(-size/2 + eyePadding, size/2 - eyePadding - eyeSize, eyeSize, eyeSize);
				drawRect(size/2 - eyePadding - eyeSize, size/2 - eyePadding - eyeSize, eyeSize, eyeSize);

			case Left:
				drawRect(-size/2 + eyePadding, -size/2 + eyePadding, eyeSize, eyeSize);
				drawRect(-size/2 + eyePadding, size/2 - eyePadding - eyeSize, eyeSize, eyeSize);

			case Right:
				drawRect(size/2 - eyePadding - eyeSize, -size/2 + eyePadding, eyeSize, eyeSize);
				drawRect(size/2 - eyePadding - eyeSize, size/2 - eyePadding - eyeSize, eyeSize, eyeSize);
		}
		endFill();
	}

	override function tick() : Bool {
		
		var ngx : Int = gx;
		var ngy : Int = gy;
		
		movingDirection = direction;
		switch(direction) {
			case Up: ngy -= 1;
			case Down: ngy += 1;
			case Left: ngx -= 1;
			case Right: ngx += 1;
		}

		updateGraphics();

		return setGridPosition(ngx, ngy);
	}

	public function setHeadColor(color : Int) {
		fillColor = color;
		updateGraphics();
	}

	public function setRandomDirection() {
		// sets a random direction
		switch(Math.floor(Math.random()*4)) {
			case 0: direction = Up;
			case 1: direction = Left;
			case 2: direction = Down;
			case 3: direction = Right;
			case _:	// not reachable ...
		}

		updateGraphics();
	}

	public function keypressed(keycode : Int) {
		
		if (Controls.is("up", keycode)) if (movingDirection == Left || direction == Right) direction = Up;
		if (Controls.is("down", keycode)) if (movingDirection == Left || direction == Right) direction = Down;
		if (Controls.is("left", keycode)) if (movingDirection == Up || direction == Down) direction = Left;
		if (Controls.is("right", keycode)) if (movingDirection == Up || direction == Down) direction = Right;

	}

	public function getGradient(count : Int) : Array<Int> {
		var colors = [];

		var start = Utils.hexToRGB(fillColor);
		var end = Utils.hexToRGB(lastColor);
		var increment = {
			r: (start.r - end.r) / count,
			g: (start.g - end.g) / count,
			b: (start.b - end.b) / count,
		};

		for (i in 1 ... count) {
			var newColor = Utils.RGBToHex(
				start.r - Math.floor(i * increment.r),
				start.g - Math.floor(i * increment.g),
				start.b - Math.floor(i * increment.b)
			);

			colors.push(newColor);
		}

		colors.push(lastColor);

		return colors;
	}
}