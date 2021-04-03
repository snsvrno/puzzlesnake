package game;

class Clock {
	
	private var timer : Float;
	public var length : Float;

	/*** the starting length of the timer. */
	private var originalLength: Float;

	public function new(length : Float) {
		originalLength = length;
		reset();
	}

	/**
	 * resets the clock to a 'initalized' state
	 */
	public function reset() {
		timer = 0;
		length = originalLength;
	}

	/**
	 * updates the clock, returns `true` if the clock hits the 
	 * length and resets, otherwise returns `false`. automatically
	 * resets the timer back to zero when reaches the lenght.
	 * @param dt 
	 * @return Bool
	 */
	public function update(dt : Float) : Bool {
		timer += dt;

		if (timer > length) {

			timer = 0;
			return true;

		} else {

			return false;

		}
	}

	#if debug
	/*** a debug function that gets a visual string value for the timer progress */
	public function debug_get_string() : String return '${Math.floor(timer*100)/100)} / ${Math.floor(length*100)/100}';
	#end
}