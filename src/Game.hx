class Game extends hxd.App {

	////////////////////////////////////////////////////////////////////

	static public var instance : Game;

	////////////////////////////////////////////////////////////////////

	private var tickTimer : Float = 0;

	// organizational objects
	public var grid : Array<Array<Tile>>;
	private var foods : Array<Food> = [];
	private var tails : Array<Tail> = [];
	private var walls : Array<Tail> = [];

	// layers
	private var playerLayer : h2d.Object;
	private var tileLayer : h2d.Object;
	private var wallsLayer : h2d.Object;
	private var foodLayer : h2d.Object;
	private var uiLayer : h2d.Object;

	// trackers and variables
	private var tickGraphic : h2d.Graphics;
	/*** how many foods should exist. */
	private var foodLimit : Int = 3;
	private var tailQueue : Array<Food> = [];
	private var player : Player;

	// the ui stuff
	private var valueTrackers : Map<Int, FoodValue> = new Map();
	private var score : Score;


	////////////////////////////////////////////////////////////////////

	public var width(default, null) : Int;
	public var height(default, null) : Int;

	////////////////////////////////////////////////////////////////////

	public function new() {
		super();
		instance = this;
	}

	override function init() {

		hxd.Window.getInstance().addEventTarget(onEvent);

		tickGraphic = new h2d.Graphics(s2d);

		uiLayer = new h2d.Object(s2d);
		uiLayer.y = - Settings.UIHEIGHT;
		foodLayer = new h2d.Object(s2d);
		wallsLayer = new h2d.Object(s2d);
		playerLayer = new h2d.Object(s2d);
		tileLayer = new h2d.Object(s2d);

		width = Settings.GRIDWIDTH;
		height = Settings.GRIDHEIGHT;
		
		// initalizes the grid
		grid = [];
		for (i in 0 ... width) {
			var column = new Array<Tile>();
			for (j in 0 ... height) {
				var tile = new Tile(tileLayer);
				tile.x = i * Tile.SIZE + Tile.SIZE/2;
				tile.y = j * Tile.SIZE + Tile.SIZE/2;
				column.push(tile);
			}
			grid.push(column);
		}

		player = new Player(playerLayer);
		// setup the UI elements
		// UI BACKGROUND FOR TESTING.
		var graphics = new h2d.Graphics(uiLayer);
		graphics.lineStyle(1,0x222222);
		graphics.beginFill(0x222222);
		graphics.drawRect(0,0,width * Tile.SIZE, Settings.UIHEIGHT);
		graphics.endFill();
		// the food scores
		for (v in 0 ... Food.variants.length) {
			var one = new FoodValue(v, uiLayer);
			one.x = 10 + v * 40;
			one.y = Settings.UIHEIGHT/2;
			valueTrackers.set(v, one);
		}
		// the actual point score.
		score = new Score(uiLayer);
		score.x = width * Tile.SIZE - 3;
		score.y = Settings.UIHEIGHT/2;


		start();
		onResize();
	}

	private function start() {

		// cleans up some stuff here.
		tickTimer = 0;
		while (foods.length > 0) foods.pop().remove();
		while (tails.length > 0) tails.pop().remove();
		while (tailQueue.length > 0) tailQueue.pop();
		while (walls.length > 0) walls.pop().remove();
		for (i in 0 ... width) {
			for (j in 0 ... height) {
				grid[i][j].clearBlocking();
			}
		}
		for (v => tracker in valueTrackers) tracker.reset();
		score.value = 0;

		// setup the new stuff.
		player.setGridPositionRandom(2);
		player.setRandomDirection();

		makeFood();
	}

	private function gameOver() {
		start();
	}

	override function update(dt:Float) {
		super.update(dt);

		tickTimer += dt;
		if (tickTimer > Settings.TICKLENGTH) {
			tickTimer = 0;

			var lastx = player.gx;
			var lasty = player.gy;

			// if the player returns false then it is dead.
			if (!player.tick()) gameOver();
			if (player.collides(tails)) gameOver();
			if (player.collides(walls)) gameOver();

			// updates the tail positions
			for (i in 0 ... tails.length) {
				var tx = tails[i].gx;
				var ty = tails[i].gy;

				tails[i].setGridPosition(lastx, lasty);

				lastx = tx;
				lasty = ty;
			}

			// checks if he should grow.
			if (tailQueue.length > 0) {
				var food = tailQueue.shift();

				var tail = new Tail(food, playerLayer);
				tail.setGridPosition(lastx, lasty);

				score.value += valueTrackers.get(tail.variant).value;

				// checks if we have 3 of a kind, if we should break the segments
				if (tails.length >= 2 && tails[tails.length-1].variant == tails[tails.length-2].variant && tails[tails.length-1].variant == food.variant) {

					// we got a match!
					var segment = tails.pop();
					//segment.remove();
					segment.setWall();
					wallsLayer.addChild(segment);
					walls.push(segment);

					var segment2 = tails.pop();
					//segment2.remove();
					segment2.setWall();
					wallsLayer.addChild(segment2);
					walls.push(segment2);

					//tail.remove();
					tail.setWall();
					wallsLayer.addChild(tail);
					walls.push(tail);

					updateEdgeGrid();
					
					// increase the multiplier.
					valueTrackers.get(tail.variant).increase();

				} else {

					tails.push(tail);

				}

				// update your color to the tail color
				if (tails.length > 0) player.setHeadColor(tails[tails.length-1].getColor());
			}

			// checks if he ate any food.
			for (f in foods) {
				if (f.gx == player.gx && f.gy == player.gy) {
					foods.remove(f);
					f.remove();
					tailQueue.push(f);
				}
			}

			// makes more food if we need to 
			makeFood();

		}
	}


	override function onResize() {

		var window = hxd.Window.getInstance();

		var width = Tile.SIZE * this.width;
		var height = Tile.SIZE * this.height;

		var scalex = window.width / (width +  2 * Settings.ZOOMPADDING);
		var scaley = window.height / (Settings.UIHEIGHT + height +  3 * Settings.ZOOMPADDING);

		s2d.setScale(Math.min(scalex, scaley));

		s2d.x = (window.width - width * s2d.scaleX)/2;
		s2d.y = Settings.UIHEIGHT * s2d.scaleY + (window.height - (height + Settings.UIHEIGHT) * s2d.scaleY)/2;
	}

	function onEvent(e : hxd.Event) {
		if (e.kind == EKeyDown) {
			player.keypressed(e.keyCode);
		}
	}

	////////////////////////////////////////////////////////////////////

	private function makeFood() {
		while (foods.length < foodLimit) {
			var f = new Food(foodLayer);

			f.setGridPositionRandom([[player], cast(foods, Array<Dynamic>), tails, walls]);

			foods.push(f);
		}
	}

	/**
	 * Goes through all the edge pieces and changes the line colors if there
	 * is a wall on the opposite side, so you can tell that you can't go there
	 * without looking across to the other side.
	 */
	private function updateEdgeGrid() {
		for (w in walls) {
			
			// is an edge piece.
			if (w.gx == 0 || w.gy == 0 || w.gx == width-1 || w.gy == height-1) {
				
				if (w.gx == 0) grid[width-1][w.gy].setBlocking(Right, w.getColor());
				else if (w.gx == width-1) grid[0][w.gy].setBlocking(Left, w.getColor());

				if (w.gy == 0) grid[w.gx][height-1].setBlocking(Down, w.getColor());
				else if (w.gy == height-1) grid[w.gx][0].setBlocking(Up, w.getColor());
			}

		}
	}
}