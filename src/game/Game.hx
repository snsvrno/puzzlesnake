package game;

class Game extends core.Window {

	////////////////////////////////////////////////////////////////////

	static public var instance : Game;
	static public function getwidth() : Int return instance.grid.width;
	static public function getheight() : Int return instance.grid.height; 

	////////////////////////////////////////////////////////////////////

	// the time keeping clock, is adjusted based on eating and
	// making walls.
	private var clock : Clock;

	public var grid : game.Grid;

	// organizational objects
	//public var grid : Array<Array<obj.Tile>>;
	private var foods : Array<obj.Food> = [];
	private var tails : Array<obj.Tail> = [];
	private var walls : Array<obj.Tail> = [];

	// layers
	private var playerLayer : h2d.Object;
	//private var tileLayer : h2d.Object;
	private var wallsLayer : h2d.Object;
	private var foodLayer : h2d.Object;
	private var uiLayer : h2d.Object;

	// trackers and variables
	/*** how many foods should exist. */
	private var foodLimit : Int = 3;
	private var tailQueue : Array<obj.Food> = [];
	private var player : obj.Player;

	// the ui stuff
	private var valueTrackers : Map<Int, ui.FoodValue> = new Map();
	private var score : ui.Score;
	// private var blankSpace : h2d.Graphics;
	private var menu : ui.Menu;

	// gameplay options
	public var colors : Int = 2;
	private var tickIncreaseRate : Float = 0.95;
	private var tickTripletRate : Float = 1.15;

	////////////////////////////////////////////////////////////////////
	
	#if debug
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	private var tickLengthDisplay : h2d.Text;
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#end

	////////////////////////////////////////////////////////////////////

	public function new() {
		super();
		instance = this;
	}

	override function init() {
		super.init();

		clock = new Clock(Settings.TICKLENGTH);

		foodLayer = new h2d.Object(world);
		wallsLayer = new h2d.Object(world);
		playerLayer = new h2d.Object(world);
		grid = new game.Grid(Settings.GRIDWIDTH, Settings.GRIDHEIGHT, world);

		// setting how big the world grid is so we have that too
		// for when we need to resize and set the viewport
		viewportHeight = grid.height * obj.Tile.SIZE;
		viewportWidth = grid.width * obj.Tile.SIZE;
		
		player = new obj.Player(playerLayer);

		initUI();

		#if debug
		// ~~~~~~~~~~~~~~~~~~~~~~~
		tickLengthDisplay = new h2d.Text(hxd.res.DefaultFont.get(), uiLayer);
		tickLengthDisplay.x = 0;
		tickLengthDisplay.y = 16;
		// ~~~~~~~~~~~~~~~~~~~~~~~
		#end

		start();
		onResize();
	}

	private function initUI() {

		// setup the UI elements
		uiLayer = new h2d.Object(world);
		uiLayer.y = - Settings.UIHEIGHT;
		
		// the ui background bar.
		var graphics = new h2d.Graphics(uiLayer);
		graphics.lineStyle(1,0x222222);
		graphics.beginFill(0x222222);
		graphics.drawRect(0,0,viewportWidth, Settings.UIHEIGHT);
		graphics.endFill();

		// the actual point score.
		score = new ui.Score(uiLayer);
		score.x = viewportWidth - 3;
		score.y = Settings.UIHEIGHT/2;

		// the menu
		menu = new ui.Menu(viewportWidth, viewportHeight, uiLayer);
	}

	private function createFoodTrackers() {

		for (k => v in valueTrackers) {
			uiLayer.removeChild(v);
			valueTrackers.remove(k);
		}

		// the food scores
		for (v in 0 ... colors) {
			var one = new ui.FoodValue(v, uiLayer);
			one.x = 10 + v * 40;
			one.y = Settings.UIHEIGHT/2;
			valueTrackers.set(v, one);
		}
	}

	private function start() {
		clock.reset();

		///////////////////////////////////////////
		// PLAYER STUFFS
		var position = grid.getRandomPosition(2);
		player.setGridPosition(position);
		player.setRandomDirection();
		// removes the older tail stuff
		while (tails.length > 0) tails.pop().remove();
		while (tailQueue.length > 0) tailQueue.pop();

		/////////////////////////////////////////
		// FOOD STUFFS
		// removes the old food
		while (foods.length > 0) foods.pop().remove();
		// makes some new food
		makeFood();


		/////////////////////////////////////////////
		// WALLS AND GRID
		// removes all the set walls.
		while (walls.length > 0) walls.pop().remove();
		// cleans up the edge wall bits that show there is a wall
		// on the other side of the board.
		grid.foreach((t) -> t.clearBlocking());

		//////////////////////////////////////////////
		// UI AND TRACKING
		score.value = 0;
		// creates the trackers based on the used foods.
		createFoodTrackers();

	}

	private function gameOver() {
		start();
	}

	private function tick() {

		/////////////////////////////////////////
		// PLAYER MOVEMENT THINGS
		// first we track the current player position for the tails
		var lastx = player.gx;
		var lasty = player.gy;
		// moves the player.
		var playerPosition = player.tick();
		var gridPosition = grid.getScreenPosition(playerPosition.gx, playerPosition.gy);
		if (gridPosition == null) gameOver(); 
		else player.setGridPosition(gridPosition);
		// checks for game over collisions
		if (player.collides(tails)) gameOver();
		if (player.collides(walls)) gameOver();

		////////////////////////////////////////////
		// UPDATES TAIL POSITIONS
		for (i in 0 ... tails.length) {
			var tx = tails[i].gx;
			var ty = tails[i].gy;

			var newposition = grid.getScreenPosition(lastx, lasty);
			tails[i].setGridPosition(newposition);

			lastx = tx;
			lasty = ty;
		}

		/////////////////////////////////////////
		// CHECKS IF WE NEED TO GROW OR EXTEND OUR SELF.
		if (tailQueue.length > 0) {
			var food = tailQueue.shift();

			var tail = new obj.Tail(food, playerLayer);
			var newposition = grid.getScreenPosition(lastx, lasty);
			tail.setGridPosition(newposition);

			// extends the tail.
			tails.push(tail);

			// adds the score.
			score.value += valueTrackers.get(tail.variant).value;

			// checks if we got the requesits for wall.
			if (makeAWall()) {
				// we need to remove the tail segments, convert them
				// to walls and keep them in place.
				for (_ in 0 ... Settings.WALLBUILDLENGTH) {
					var segment = tails.pop();
					segment.setWall();
					// playerLayer.removeChild(segment);
					wallsLayer.addChild(segment);
					walls.push(segment);
				}

				// update the edge grid so we can see walls that 
				// are on the other side of the board (if we are using wraparound)
				updateEdgeGrid();

				// adjust the multiplier.
				valueTrackers.get(tail.variant).increase();
				
				// reset the time by some amount
				clock.length *= tickTripletRate;
			}

			// update your color to the tail color
			if (tails.length > 0) player.setHeadColor(tails[tails.length-1].getColor());
		}

		/////////////////////////////////////////
		// CHECKS ON THE EATING!
		for (f in foods) {
			if (f.gx == player.gx && f.gy == player.gy) {
				// removes the food from the world
				foods.remove(f);
				f.remove();

				// adds the food to the player
				tailQueue.push(f);

				// increments the speed! if we eat something.
				clock.length *= tickIncreaseRate;
			}
		}

		///////////////////////////////////////////
		// REPOPULATES FOOD.
		makeFood();

	}

	override function update(dt:Float) {
		super.update(dt);

		#if debug
		tickLengthDisplay.text = clock.debug_get_string();
		#end

		if (clock.update(dt)) tick();
	}

	override function onEvent(e : hxd.Event) {

		if (e.kind == EKeyDown && Controls.is("cancel", e.keyCode)) {
			toggleMenu();
		}

		// the menu items
		if (menu.parent != null && e.kind == EKeyDown) {
			menu.keypressed(e.keyCode);
		}

		// the ingame events
		if (menu.parent == null && e.kind == EKeyDown) {
			player.keypressed(e.keyCode);
		}
	}

	////////////////////////////////////////////////////////////////////

	
	private function makeFood() {
		while (foods.length < foodLimit) {
			var position = grid.getRandomPosition([[player], cast(foods, Array<Dynamic>), tails, walls]);
			var f = new obj.Food(colors, foodLayer);
			f.setGridPosition(position);
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
			if (grid.isEdge(w.gx, w.gy)) {
				if (w.gx == 0) grid.getTile(grid.width-1, w.gy).setBlocking(Right, w.getColor());
				else grid.getTile(0, w.gy).setBlocking(Left, w.getColor());

				if (w.gy == 0) grid.getTile(w.gx, grid.height-1).setBlocking(Down, w.getColor());
				else grid.getTile(w.gx, 0).setBlocking(Up, w.getColor());
			}

		}
	}

	/**
	 * function to start the game, from the menu
	 */
	public function startGame() {
		start();
		uiLayer.removeChild(menu);
	}

	public function toggleMenu() {
		if (menu.parent == null) uiLayer.addChild(menu);
		else uiLayer.removeChild(menu);
	}

	private function makeAWall() : Bool {
		// first we makes sure we have enough tail pieces to check
		// for a wall.
		if (tails.length >= Settings.WALLBUILDLENGTH) {
			// the last color, now we make sure all of the colors
			// for the requisit length are the same.
			var variant : Int = tails[tails.length-1].variant;
			var passed = true;
			for (i in 1 ... Settings.WALLBUILDLENGTH) {
				if (tails[tails.length - 1 - i].variant != variant) {
					passed = false;
					break;
				}
			}

			return passed;
		}

		return false;
	}

	public function setScanlinesEffect(state : Bool) crtFilter.enable = state;
	public function hasScanlines() : Bool return crtFilter.enable;
	public function setBubbleEffect(state : Bool) bubbleFilter.enable = state;
	public function hasBubble() : Bool return bubbleFilter.enable;
}