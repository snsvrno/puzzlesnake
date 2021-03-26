class Game extends hxd.App {

	////////////////////////////////////////////////////////////////////

	inline static private var GRIDWIDTH : Int = 10;
	inline static private var GRIDHEIGHT : Int = 10;
	inline static private var ZOOMPADDING : Int = 10;
	inline static private var TICKLENGTH : Float = 0.3;

	inline static private var TICKGCOLOR : Int = 0xFF0000;
	inline static private var TICKGOPACITY : Float = 0.3;

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

	// trackers and variables
	private var tickGraphic : h2d.Graphics;
	/*** how many foods should exist. */
	private var foodLimit : Int = 3;
	private var tailQueue : Array<Food> = [];
	private var player : Player;

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

		foodLayer = new h2d.Object(s2d);
		wallsLayer = new h2d.Object(s2d);
		playerLayer = new h2d.Object(s2d);
		tileLayer = new h2d.Object(s2d);

		width = GRIDWIDTH;
		height = GRIDHEIGHT;
		
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
		if (tickTimer > TICKLENGTH) {
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
				player.setHeadColor(food.getColor());

				var tail = new Tail(food, playerLayer);
				tail.setGridPosition(lastx, lasty);

				// checks if we have 3 of a kind, if we should break the segments
				if (tails.length >= 2 && tails[tails.length-1].variant == tails[tails.length-2].variant && tails[tails.length-1].variant == food.variant) {

					// we got a match!
					var segment = tails.pop();
					//segment.remove();
					wallsLayer.addChild(segment);
					walls.push(segment);

					var segment2 = tails.pop();
					//segment2.remove();
					wallsLayer.addChild(segment2);
					walls.push(segment2);

					//tail.remove();
					wallsLayer.addChild(tail);
					walls.push(tail);

				} else {

					tails.push(tail);

				}
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

		var width = Tile.SIZE * GRIDWIDTH;
		var height = Tile.SIZE * GRIDHEIGHT;

		var scalex = window.width / (width +  2 * ZOOMPADDING);
		var scaley = window.height / (height +  2 * ZOOMPADDING);

		s2d.setScale(Math.min(scalex, scaley));

		s2d.x = (window.width - width * s2d.scaleX)/2;
		s2d.y = (window.height - height * s2d.scaleY)/2;
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

			f.setGridPositionRandom([[player], cast(foods, Array<Dynamic>), tails]);

			foods.push(f);
		}
	}
}