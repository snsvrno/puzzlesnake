class Controls {

	static private var instance : Controls = new Controls();

	static public function is(name : String, key : Int) : Bool {
		return instance.keys.get(key) == name;
	}
	
	public var keys : Map<Int, String>;
	
	public function new() {
		keys = [
			hxd.Key.A => "left",
			hxd.Key.LEFT => "left",

			hxd.Key.D => "right",
			hxd.Key.RIGHT => "right",

			hxd.Key.W => "up",
			hxd.Key.UP => "up",

			hxd.Key.S => "down",
			hxd.Key.DOWN => "down",

			hxd.Key.ESCAPE => "cancel",
			hxd.Key.ENTER => "confirm",
		];
	}
	
}