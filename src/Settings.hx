class Settings {

	/////////////////////////////////////////////////////////////////////////
	// STATIC INLINE SETTINGS / CONSTANTS

	/*** how many cells are there in the x */
	inline static public var GRIDWIDTH : Int = 20;
	/*** how many cells are there in the y */
	inline static public var GRIDHEIGHT : Int = 14;
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
	/*** the color of when a particular menu item is selected*/
	inline static public var MENUITEMOVERCOLOR : Int = 0x666666;
	/*** the UI background color */
	inline static public var UIBACKGROUNDCOLOR : Int = 0x222222;
	/*** the boarder size for the UI Background */
	inline static public var UIBORDERSIZE : Int = 1;
	/*** the boarder color for the UI Background */
	inline static public var UIBORDERCOLOR : Int = 0x222222;

	/*** food indicator size */
	inline static public var UIFOODSIZE : Int = 6;
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

		//var values = hxd.Save.load();
		//trace(values);
	}

	static public function save() {
		hxd.Save.save(instance);
	}

	/////////////////////////////////////////////////////////////////////////////
	// Instance Stuff.

	private var foodColors : Array<Int>;

	// this is tracked here in the local settings, but can be accessed by the 
	// rest the app from `Controls` singleton.
	private var controls : Controls;

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

		controls = new Controls();
	}

}