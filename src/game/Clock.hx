package game;

class Clock {
	
	/*** the starting length of the timer. */
	private var originalLength: Float;
	/*** the actual timer, keeps track of the current time. */
	private var timer : Float;
	/*** the target of the timer, or the length of the timer. */
	public var length : Float;

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