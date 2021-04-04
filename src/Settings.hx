class Settings {

	/////////////////////////////////////////////////////////////////////////
	// STATIC INLINE SETTINGS / CONSTANTS

	/*** how many cells are there in the x */
	inline static public var GRIDWIDTH : Int = 20;
	/*** how many cells are there in the y */
	inline static public var GRIDHEIGHT : Int = 14;
	/*** how much padding is there around the playable space? */
	inline static public var ZOOMPADDING : Int = 10;
	/*** what is the starting tick (turn) length in seconds */
	inline static public var TICKLENGTH : Float = 0.25;
	/*** is there wrap around the world, or are the edges dangerous? */
	inline static public var WORLDWRAP : Bool = true;

	/*** standard grid size */
	inline static public var GRIDSIZE : Int = 16;
	/*** grid color */
	inline static public var GRIDCOLOR : Int = 0x222222;
	/*** grid opacity */
	inline static public var GRIDOPACITY: Float = 1;
	/*** grid line thickness */
	inline static public var GRIDTHICKNESS : Int = 1;
	
	/** how many like-minded colors are required to build a wall? */
	inline static public var WALLBUILDLENGTH : Int = 3;

	//////// UI & GRAPHICS ////////////////////////////
	/*** the game background color */
	inline static public var BGCOLOR : Int = 0x0f0d0e;
	/*** the height of the UI bar.*/
	inline static public var UIHEIGHT : Int = 20;
	/*** the color of when a particular menu item is selected*/
	inline static public var MENUITEMOVERCOLOR : Int = 0x666666;

	/////////////////////////////////////////////////////////////////////////

	static public var instance : Settings;

	static public function getFoodColor(position : Int) : Null<Int> {		
		
		if (position < 0 || position > instance.foodColors.length - 1) return null;
		else return instance.foodColors[position];
	}

	/**
	 * creates a new settings, attempts to load it from the save, and if it doesn't
	 * exist then uses the default stuff.
	 */
	static public function load() {
		instance = new Settings();
	}

	private var foodColors : Array<Int>;

	private function new() {

		// setup the food colors that we are using.
		foodColors = [
			0xEF5412, // red
			0xf5e400, // yellow
			0x0662FE, // blue
			0x12FF23, // green
			0xc840f5, // violet
			0xcc7b02, // orange
		];
	}

}