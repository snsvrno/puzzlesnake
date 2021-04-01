class Game extends hxd.App {

	////////////////////////////////////////////////////////////////////

	static public var instance : Game;

	////////////////////////////////////////////////////////////////////

	private var tickTimer : Float = 0;
	private var tickLength : Float = Settings.TICKLENGTH;

	private var world : h2d.Object;

	// organizational objects
	public var grid : Array<Array<obj.Tile>>;
	private var foods : Array<obj.Food> = [];
	private var tails : Array<obj.Tail> = [];
	private var walls : Array<obj.Tail> = [];

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
	private var tailQueue : Array<obj.Food> = [];
	private var player : obj.Player;

	// the ui stuff
	private var valueTrackers : Map<Int, ui.FoodValue> = new Map();
	private var score : ui.Score;
	private var blankSpace : h2d.Graphics;
	private var menu : ui.Menu;

	// shaders
	private var bubble : shaders.Bubble;
	private var bubbleFilter : h2d.filter.Shader<shaders.Bubble>;
	private var crt : shaders.CRT;
	private var crtFilter : h2d.filter.Shader<shaders.CRT>;
	private var filtergroup : h2d.filter.Group;

	// gameplay options
	public var colors : Int = 2;
	private var tickIncreaseRate : Float = 0.95;
	private var tickTripletRate : Float = 1.15;
	
	#if debug
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	private var tickLengthDisplay : h2d.Text;
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	#end

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

		world = new h2d.Object(s2d);

		blankSpace = new h2d.Graphics(world);

		tickGraphic = new h2d.Graphics(world);

		foodLayer = new h2d.Object(world);
		wallsLayer = new h2d.Object(world);
		playerLayer = new h2d.Object(world);
		tileLayer = new h2d.Object(world);

		width = Settings.GRIDWIDTH;
		height = Settings.GRIDHEIGHT;
		
		// initalizes the grid
		grid = [];
		for (i in 0 ... width) {
			var column = new Array<obj.Tile>();
			for (j in 0 ... height) {
				var tile = new obj.Tile(tileLayer);
				tile.x = i * obj.Tile.SIZE + obj.Tile.SIZE/2;
				tile.y = j * obj.Tile.SIZE + obj.Tile.SIZE/2;
				column.push(tile);
			}
			grid.push(column);
		}

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
		graphics.drawRect(0,0,width * obj.Tile.SIZE, Settings.UIHEIGHT);
		graphics.endFill();

		// the actual point score.
		score = new ui.Score(uiLayer);
		score.x = width * obj.Tile.SIZE - 3;
		score.y = Settings.UIHEIGHT/2;

		// the menu
		menu = new ui.Menu(width * obj.Tile.SIZE, height * obj.Tile.SIZE, uiLayer);

		// makes the shaders
		filtergroup = new h2d.filter.Group();
		crt = new shaders.CRT();
		crtFilter = new h2d.filter.Shader(crt);
		filtergroup.add(crtFilter);
		bubble = new shaders.Bubble();
		bubbleFilter = new h2d.filter.Shader(bubble);
		filtergroup.add(bubbleFilter);
		s2d.filter = filtergroup;
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
		// recreates the trackers
		createFoodTrackers();

		score.value = 0;

		// setup the new stuff.
		player.setGridPositionRandom(2);
		player.setRandomDirection();

		// need to reset the speed when we start a new game.
		tickLength = Settings.TICKLENGTH;

		makeFood();
	}

	private function gameOver() {
		start();
	}

	override function update(dt:Float) {
		super.update(dt);

		#if debug
		tickLengthDisplay.text = '${Math.floor(tickTimer*100)/100)} / ${Math.floor(tickLength*100)/100}';
		#end

		tickTimer += dt;
		if (tickTimer > tickLength) {
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

				var tail = new obj.Tail(food, playerLayer);
				tail.setGridPosition(lastx, lasty);

				score.value += valueTrackers.get(tail.variant).value;

				// checks if we have 3 of a kind, if we should break the segments
				// and make a wall.
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

					// reset the time by some amount
					tickLength *= tickTripletRate;

				} else {

					tails.push(tail);

				}

				// update your color to the tail color
				if (tails.length > 0) player.setHeadColor(tails[tails.length-1].getColor());
			}

			// checks if he ate any food.
			for (f in foods) {
				if (f.gx == player.gx && f.gy == player.gy) {
					// removes the food from the world
					foods.remove(f);
					f.remove();

					// adds the food to the player
					tailQueue.push(f);

					// increments the speed! if we eat something.
					tickLength *= tickIncreaseRate;
				}
			}

			// makes more food if we need to 
			makeFood();

		}
	}


	override function onResize() {

		var window = hxd.Window.getInstance();

		var width = obj.Tile.SIZE * this.width;
		var height = obj.Tile.SIZE * this.height;

		var scalex = window.width / (width +  2 * Settings.ZOOMPADDING);
		var scaley = window.height / (Settings.UIHEIGHT + height +  3 * Settings.ZOOMPADDING);

		world.setScale(Math.min(scalex, scaley));

		world.x = (window.width - width * world.scaleX)/2;
		world.y = Settings.UIHEIGHT * world.scaleY + (window.height - (height + Settings.UIHEIGHT) * world.scaleY)/2;

		blankSpace.clear();
		blankSpace.beginFill(Settings.BGCOLOR);
		blankSpace.drawRect(-world.x / world.scaleX,-world.y / world.scaleY, window.width / world.scaleX, window.height / world.scaleY);
		blankSpace.endFill();

		bubble.backgroundColor.setColor(Settings.BGCOLOR);

		// need to update the crt shader so we know the 
		// pixel size
		crt.screenHeight = window.height;
		crt.screenWidth = window.width;

	}

	function onEvent(e : hxd.Event) {

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
			var f = new obj.Food(colors, foodLayer);

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

	public function setScanlinesEffect(state : Bool) crtFilter.enable = state;
	public function hasScanlines() : Bool return crtFilter.enable;
	public function setBubbleEffect(state : Bool) bubbleFilter.enable = state;
	public function hasBubble() : Bool return bubbleFilter.enable;
}