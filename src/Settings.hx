class Settings {

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