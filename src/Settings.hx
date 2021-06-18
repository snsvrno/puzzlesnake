class Settings {

	static public var instance : Settings;

	static public function getFoodColor(position : Int) : Null<Int> {		
		
		if (position < 0 || position > instance.palette.foods.length - 1) return null;
		else return instance.palette.foods[position];
	}

	static public function getFoodColors() : Array<Int> return instance.palette.foods.copy();

	static public var backgroundColor(get, null) : Int;
	static private function get_backgroundColor() : Int return instance.palette.background;

	static public var wallColor(get, null) : Int;
	static private function get_wallColor() : Int return instance.palette.wall; 

	static public var ui1Color(get, null) : Int;
	static private function get_ui1Color() : Int return instance.palette.ui1; 

	static public var ui2Color(get, null) : Int;
	static private function get_ui2Color() : Int return instance.palette.ui2; 

	static public var uiSelectedColor(get, null) : Int;
	static private function get_uiSelectedColor() : Int return instance.palette.uiSelected; 

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

	static public function setPalette(p : structures.ColorPalette) {
		game.Game.log('changing palette to ${p.name}');
		instance.palette = p;

		// now we need to force everything to redraw.
		game.Game.forceRedraw();
	}

	/////////////////////////////////////////////////////////////////////////////
	// Instance Stuff.

	private var palette : structures.ColorPalette;

	// this is tracked here in the local settings, but can be accessed by the 
	// rest the app from `Controls` singleton.
	private var controls : Controls;

	private function new() {
		controls = new Controls();
		palette = palettes.Default.palette;
	}

}