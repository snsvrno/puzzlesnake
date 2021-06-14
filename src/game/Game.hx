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

	/**
	 * reloads the game and restarts it, but doesn't 
	 * remove menus and goes through the complete
	 * starting process
	 * 
	 * does reset the score and the current player game
	 * progress
	 * 
	 * mainly used for changing settings before playing
	 * that instance so that the changes are reflected
	 * in the demo background
	 */
	static public function hotReload() {
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
	private var foods : obj.Container<obj.Food>;
	// private var foods : Array<obj.Food> = [];
	private var tails : Array<obj.Tail> = [];
	//private var walls : Array<obj.Tail> = [];
	private var walls : obj.Container<obj.Wall>;

	// layers that contain all the sprites / display objects for the game.
	// doing this route so I can manage draw order and easily show / hide
	// different types of stuff.
	private var playerLayer : h2d.Object;
	//private var wallsLayer : h2d.Object;
	// private var foodLayer : h2d.Object;
	// private var uiLayer : h2d.Object;

	// trackers and variables
	/*** how many foods should exist. */
	private var tailQueue : Array<obj.Food> = [];
	private var player : obj.Player;
	/*** tracks when we should make a new steroid */
	private var steroidGenTracker : Int;

	/*** all the specific gamplay options */
	public var options : structures.GameplayOptions;
	public var pause : Bool = false;

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
			tickMovement: 0.9999,
			foodGenBaseCut: 0.25,
			foodGenPlayerCut: 0.75,
		};

		clock = new Clock(options.startingTickSpeed);

		foods = new obj.Container(world);
		walls = new obj.Container(world);
		// foodLayer = new h2d.Object(world);
		// wallsLayer = new h2d.Object(world);
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
	 * called when we want to quit the game.
	 * do some kind of cleanup logic here
	 */
	public function quit() {
		hxd.System.exit();
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
		while (foods.length > 0) foods.pop();
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
		// UPDATE ALL OBJECTS
		// tells all the objects that a tick has passed
		obj.GridObject.runAllTicks();

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

		// does some basic time incrementation
		clock.length *= options.tickMovement;
		
		// checks for game over collisions
		if (player.collides(tails)) gameOver();
		if (player.collides(walls.iter(), checkCollisionsIfEatableWall)) gameOver();

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

				#if debug
				// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				log('making a wall');
				// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				#end

				// we need to remove the tail segments, convert them
				// to walls and keep them in place.
				for (_ in 0 ... settings.Game.WALL_BUILD_LENGTH) {
					var segment = tails.pop();

					var wall = new obj.Wall(segment.variant);
					wall.setGridPosition(segment.getGridPosition());

					playerLayer.removeChild(segment);
					walls.addObj(wall);
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

			// since we ate a food we should check if we need to populate more 
			// food
			makeFood();
		}

		/////////////////////////////////////////
		// CHECKS ON THE EATING!

		// did we eat a food.
		for (f in foods.iter()) {
			if (f.gx == player.gx && f.gy == player.gy) {
				eatFood(f);
				
				// we update the steroid tracker, because we create a steroid
				// ever XX foods.
				steroidGenTracker += 1;
			}
		}

		// did we eat a wall??
		for (w in walls.iter()) {
			if (w.gx == player.gx && w.gy == player.gy) {
				eatWall(w);
				
				// we update the steroid tracker, because we create a steroid
				// ever XX foods.
				steroidGenTracker += 1;
			}
		}

		///////////////////////////////////////////
		// REPOPULATES FOOD.
		if (steroidGenTracker >= settings.Game.STEROID_COUNTER) {
			steroidGenTracker = 0;
			makeSteroid();
		} 
	}

	/**
	 * eats the food and does whatever else needs to be done.
	 */
	private function eatFood(f : obj.Food) {

		// first checks if this is actually a steroid.
		if (f.foodType == Steroid) {
			eatSteroid(cast(f, obj.Steroid));
			return;
		}

		#if debug
		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		log('ate food ${f.variant} at ${f.gx}, ${f.gy}');
		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		#end

		// removes the food from the world
		foods.removeObj(f);

		// adds the food to the player
		tailQueue.push(f);

		// increments the speed! if we eat something.
		clock.length *= options.tickEatFood;

		// updates the score.
		ui.updateScore(ui.getFood(f.variant).value * f.value);
	}

	private function eatSteroid(s : obj.Steroid) {
		
		#if debug
		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		log('ate steroid ${s.variant} at ${s.gx}, ${s.gy}');
		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		#end

		// goes through the walls and sets them to eatable.
		for (w in walls.iter()) {
			if (w.variant == s.variant) w.setEatable();
		}
	}

	private function eatWall(w : obj.Wall) {


		#if debug
		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		log('ate wall ${w.variant} at ${w.gx}, ${w.gy}');
		// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		#end

		walls.removeObj(w);
		
		// updates the score.
		ui.updateScore(ui.getFood(w.variant).value * w.value);
	}

	override function update(dt:Float) {
		super.update(dt);

		if (pause) return;

		if (clock.update(dt)) tick();

		obj.GridObject.runAppUpdates(dt);
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

		// toggle fullscreen with a button. (F12)
		if (e.kind == EKeyDown && e.keyCode == hxd.Key.F12) {
			var window = hxd.Window.getInstance();
			if (window.displayMode == Borderless) window.displayMode = Windowed;
			else window.displayMode = Borderless;
		}
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

	/**
	 * makes food for the player to eat.
	 */
	private function makeFood() {
		while (foods.length < options.foodLimit) {
			var position = grid.getRandomPosition([[player], cast(foods.iter(), Array<Dynamic>), tails, walls.iter()]);

			var f = new obj.Food(options.colors);

			///////////
			// the random smart generation
			// what we are trying to do is to check how many pieces are in the player, and weight colors that are closer
			// to becoming walls first, so that hopefully the piece the player needs is spawned and the player can make
			// a wall
			var ranges : Array<Float> = [ ];

			// the standard chance, this is equal across all colors.
			var baseChance = 1 / options.colors;
			// we check if we have any tail, if we don't have a tail then that means
			// we will only be using the baseChance, so we weight it to 1.0.
			var baseCut = if (tails.length == 0) 1.0; else { options.foodGenBaseCut; };
			// we make the basic ranges using the baseChance.
			for (_ in 0 ... options.colors) ranges.push(baseChance * baseCut);

			if (tails.length > 0) {
				// if we have tails then we need to count how many colors are in the tail
				// and what position so we can weight them into the chances too.
				
				// what we need to divide these numbers by so they equate 1
				// came up with this by running some examples of what i wanted
				// in a spreadsheet.
				var diviser = if(tails.length == 1) 1;
				else 1 + 0.5 * (tails.length-1);

				for (i in 0 ... options.colors) {
					// we check each of the valid colors.

					// determines what the probability count is, this isn't a straight
					// count but instead something to scale it so all the tail "counts"
					// will equal 1.
					var count = 0.0;
					for (ti in 0 ... tails.length) {

						if (tails[ti].variant == i) {
							// if this variant is the color we are looking for, then we count
							// its weighted probability score, this is determined by its position
							// in the tail `score = position / total length` so if it was 3rd and
							// the tail length was 6 then it would be `3/6 == 0.5`
							var positionalValue = (ti+1) / tails.length;

							// we then add it to the total count for this color, and use the diviser.
							// this normalizes the score so that when suming all the counts for all
							// the colors it will equal 1.0
							count += positionalValue / diviser;
						}

					}
					// scales it per the player cut and adds it to the total range for that color.
					ranges[i] += count * options.foodGenPlayerCut;
				}
			}

			// now we actually makes the ranges so we can more easily check the random number with them
			for (i in 1 ... ranges.length) ranges[i] += ranges[i-1];

			// and now we spawn a random number and check it against the ranges.
			var random = Math.random();

			for (i in 0 ... ranges.length) {
				if (i == 0) {
					if (random <= ranges[i]) { f.setVariant(i); break; }
				} else {
					if (ranges[i-1] <= random && random <= ranges[i]) { f.setVariant(i); break; }
				}
			}

			///////////

			f.setGridPosition(position);
			foods.addObj(f);

			if (console != null) console.log('making food ${f.variant} at ${position.gx}, ${position.gy}');
		}
	}

	/**
	 * makes a special kind of food that allows the player to eat walls.
	 */
	private function makeSteroid() {
		if (foods.length < options.foodLimit) {
			var position = grid.getRandomPosition([[player], cast(foods.iter(), Array<Dynamic>), tails, walls.iter()]);

			// gets a random color of a wall that exists.
			var color = {
				var colors : Array<Int> = [];
				for (w in walls.iter()) {
					var c = w.variant;
					if (!colors.contains(c)) colors.push(c);
				}

				if (colors.length == 0) {
					console.log('can\'t make a steroid..');
					return;
				}

				var i = Math.floor(Math.random() * colors.length);
				colors[i];
			};

			var s = new obj.Steroid(color);
			s.setGridPosition(position);
			foods.addObj(s);

			if (console != null) console.log('making steroid.');
		} 
	}

	/**
	 * Goes through all the edge pieces and changes the line colors if there
	 * is a wall on the opposite side, so you can tell that you can't go there
	 * without looking across to the other side.
	 */
	private function updateEdgeGrid() {
		
		for (w in walls.iter()) {
			if (grid.isEdge(w.gx, w.gy)) {
				if (w.gx == 0) grid.getTile(grid.width - 1, w.gy).setBlocking(Right, w.getOutlineColor());
				else if (w.gx == grid.width-1) grid.getTile(0, w.gy).setBlocking(Left, w.getOutlineColor());

				if (w.gy == 0) grid.getTile(w.gx, grid.height - 1).setBlocking(Down, w.getOutlineColor());
				else if (w.gy == grid.height - 1) grid.getTile(w.gx, 0).setBlocking(Up, w.getOutlineColor());
			}
		}
	}

	/**
	 * used to cancel the collision death event if the wall is eatable.
	 * @param wall 
	 * @return Bool
	 */
	private function checkCollisionsIfEatableWall(wall : Dynamic) : Bool {
		var w = cast(wall, obj.Wall);
		if (w.eatable) return true;
		return false;
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