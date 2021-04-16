package game;

class Game extends core.Window {

	////////////////////////////////////////////////////////////////////
	// STATIC STUFF

	static public var instance : Game;

	static public function getwidth() : Int return instance.grid.width;
	static public function getheight() : Int return instance.grid.height;

	static public function newGame() { 
		
		// we remove all the menus
		while (instance.menu.length > 0) shiftMenu();
	
		instance.start();
	}

	static public function setMenu(menu : menu.Menu) {

		// remove the current menu from the display.
		if (instance.menu[0] != null) {
			instance.world.removeChild(instance.menu[0]);
		}

		// adds this new menu to the front.
		instance.menu.unshift(menu);
		instance.world.addChild(menu);
	}

	/*** removes the currently active menu. */
	static public function shiftMenu() {
		var menu = instance.menu.shift();
		if (menu != null) {
			instance.world.removeChild(menu);

			// if we have more menu items then lets set the next one
			if (instance.menu.length > 0) instance.world.addChild(instance.menu[0]);
			// if we don't have any more then let's check if we are paused
			// and then unpause the game.
			else if (instance.pause) instance.pause = false;
		}
	}

	#if debug
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	static public function log(text : String) instance.console.log(text);
	static public var debug_graphics : debug.BoundsManager = new debug.BoundsManager();
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#end

	////////////////////////////////////////////////////////////////////

	#if debug
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	private var console : h2d.Console;
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#end

	// the time keeping clock, is adjusted based on eating and
	// making walls.
	private var clock : Clock;

	public var grid : game.Grid;

	public var ui : ui.Manager;

	public var menu : Array<menu.Menu> = [];

	// organizational objects
	private var foods : Array<obj.Food> = [];
	private var tails : Array<obj.Tail> = [];
	private var walls : Array<obj.Tail> = [];

	// layers that contain all the sprites / display objects for the game.
	// doing this route so I can manage draw order and easily show / hide
	// different types of stuff.
	private var playerLayer : h2d.Object;
	private var wallsLayer : h2d.Object;
	private var foodLayer : h2d.Object;
	// private var uiLayer : h2d.Object;

	// trackers and variables
	/*** how many foods should exist. */
	private var tailQueue : Array<obj.Food> = [];
	private var player : obj.Player;

	/*** all the specific gamplay options */
	private var options : structures.GameplayOptions;
	private var pause : Bool = false;

	////////////////////////////////////////////////////////////////////

	public function new() {
		super();
		instance = this;

		// loads the settings
		Settings.load();
	}

	override function init() {
		super.init();

		// sets the default options
		options = {
			wallLength: 3,
			colors: 2,
			startingTickSpeed: 0.25,
			tickMakeWall: 1.15,
			tickEatFood: 0.95,
			foodLimit: 3,
		};

		clock = new Clock(options.startingTickSpeed);

		foodLayer = new h2d.Object(world);
		wallsLayer = new h2d.Object(world);
		playerLayer = new h2d.Object(world);
		grid = new game.Grid(settings.Game.GRID_WIDTH, settings.Game.GRID_HEIGHT, world);

		var uiheight = 20;

		// setting how big the world grid is so we have that too
		// for when we need to resize and set the viewport
		viewportHeight = grid.height * settings.Grid.SIZE + uiheight;
		viewportWidth = grid.width * settings.Grid.SIZE;
		viewportPadding = new structures.Padding(50,50,50,50);
		
		player = new obj.Player(playerLayer);

		// initUI();
		ui = new ui.Manager(viewportWidth, uiheight, world);
		grid.y = uiheight;

		// creates the starting menu
		setMenu(menus.Main.main(viewportWidth, viewportHeight));

		start();
		onResize();

		#if debug
		// ~~~~~~~~~~~~~~~~~~~~~~~

		console = new h2d.Console(hxd.res.DefaultFont.get(), s2d);
		console.addCommand("debug", [{ name : "state", opt : false, t : h2d.Console.ConsoleArg.ABool }], debug_graphics.show);
		log('console started');
		// sets all the graphics to hide by default.
		debug_graphics.show(false);

		// ~~~~~~~~~~~~~~~~~~~~~~~
		#end
	}

	/**
	 * configures the game for a new play session (a new game)
	 */
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
		//score.value = 0;
		// creates the trackers based on the used foods.
		ui.createFoodIndicators(options.colors);
		ui.createScore();

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
			// score.value += valueTrackers.get(tail.variant).value;

			// checks if we got the requesits for wall.
			if (makeAWall()) {

				log('making a wall');

				// we need to remove the tail segments, convert them
				// to walls and keep them in place.
				for (_ in 0 ... settings.Game.WALL_BUILD_LENGTH) {
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
				ui.getFood(tail.variant).increase();
				
				// reset the time by some amount
				clock.length *= options.tickMakeWall;
			}

			// update your color to the tail color
			if (tails.length > 0) player.setHeadColor(tails[tails.length-1].getColor());
		}

		/////////////////////////////////////////
		// CHECKS ON THE EATING!
		for (f in foods) {
			if (f.gx == player.gx && f.gy == player.gy) {
				eatFood(f);
			}
		}

		///////////////////////////////////////////
		// REPOPULATES FOOD.
		makeFood();

	}

	/**
	 * eats the food and does whatever else needs to be done.
	 */
	private function eatFood(f : obj.Food) {

		#if debug
		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		log('ate food ${f.variant} at ${f.gx}, ${f.gy}');
		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		#end

		// removes the food from the world
		foods.remove(f);
		f.remove();

		// adds the food to the player
		tailQueue.push(f);

		// increments the speed! if we eat something.
		clock.length *= options.tickEatFood;

		// updates the score.
		ui.updateScore(ui.getFood(f.variant).value * f.value);
	}

	override function update(dt:Float) {
		super.update(dt);

		if (pause) return;

		if (clock.update(dt)) tick();
	}

	override function onEvent(e : hxd.Event) {

		#if debug
		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// open the console
		if (e.kind == EKeyDown && e.keyCode == hxd.Key.QWERTY_TILDE) {
			// toggles the console.
			if (console.isActive()) console.hide();
			else console.show();

			// we cancel checking the rest of items for events.
			return;
		}

		// check if the console is open, and if it is then we
		// ignore all event processing.
		if (console.isActive()) return;
		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		#end

		if (menu.length > 0) {
			// if we have menus in the stack then all the inputs
			// will be sent to the menu.

			if (e.kind == EKeyDown) menu[0].keypressed(e.keyCode);

		} else {

			if (e.kind == EKeyDown) {

				if (Controls.is("cancel", e.keyCode)) {
					// we hit the cancel button which starts the menu.
					setMenu(menus.Main.main(viewportWidth, viewportHeight));

					// we should also pause the game if we are actually playing a game
					pause = true;

					return;
				}

				player.keypressed(e.keyCode);
			}

		}
	}

	////////////////////////////////////////////////////////////////////

	
	private function makeFood() {
		while (foods.length < options.foodLimit) {
			var position = grid.getRandomPosition([[player], cast(foods, Array<Dynamic>), tails, walls]);
			var f = new obj.Food(options.colors, foodLayer);
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

	private function makeAWall() : Bool {
		// first we makes sure we have enough tail pieces to check
		// for a wall.
		if (tails.length >= settings.Game.WALL_BUILD_LENGTH) {
			// the last color, now we make sure all of the colors
			// for the requisit length are the same.
			var variant : Int = tails[tails.length-1].variant;
			var passed = true;
			for (i in 1 ... settings.Game.WALL_BUILD_LENGTH) {
				if (tails[tails.length - 1 - i].variant != variant) {
					passed = false;
					break;
				}
			}

			return passed;
		}

		return false;
	}
}