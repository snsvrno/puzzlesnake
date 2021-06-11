package settings;

class Game {

	/*** how many cells are there in the x */
	inline static public var GRID_WIDTH : Int = 20;
	/*** how many cells are there in the y */
	inline static public var GRID_HEIGHT : Int = 14;
	/*** is there wrap around the world, or are the edges dangerous? */
	inline static public var WORLD_WRAP : Bool = true;

	/** how many like-minded colors are required to build a wall? */
	inline static public var WALL_BUILD_LENGTH : Int = 3;

	//////// UI & GRAPHICS ////////////////////////////
	/*** the game background color */
	inline static public var BACKGROUND_COLOR : Int = 0x0f0d0e;
	/*** the off-color color of the wall, usually the core color (or outline if eatable) */
	inline static public var WALL_COLOR : Int = 0x222222;

	//////// STERIOD GAMEPLAY SETTINGS  ////////////////////////////
	/*** how often should we try and make a steroid, looking at foods eaten */
	inline static public var STEROID_COUNTER : Int = 10;

	/*** how long should a steroid be valid until it turns into a food */
	inline static public var STEROID_LIFE : Int = 20;

	//////// STERIOD TRANSITION SETTINGS  ////////////////////////////

	/**
	 * how long does the effects of an eaten steroid last .i.e how much time (turns)
	 * does the player have to eat the walls.
	 */
	inline static public var STEROID_LASTING_TIME : Int = 24;

	/**
	 * how many segments to draw the circle, the changing animation is 
	 * the segments reducing so it turns back into a square.
	 */
	inline static public var STEROID_SEGMENTS : Int = 12;
	/**
	 * the transformation speed in segments per second, this is the 
	 * transformation back into a food
	 */
	inline static public var STEROID_TRANSFORM_SPEED : Int = 12;
	/**
	 * how fast the steroid rotates when transforming into a food
	 */
	inline static public var STEROID_TRANSFORM_ROTATION_SPEED : Float = 10;
	/**
	 * the maximum scale for the steroid when it transforms into a food
	 */
	inline static public var STEROID_TRANSFORM_SCALE : Float = 1.25;
	/**
	 * how fast should the steroid scale back down to normal size after
	 * it hits its maximum scale factor defined in `STEROID_TRANSFORM_SCALE`
	 */
	inline static public var STEROID_TRANSFORM_SHRINK_SPEED : Float = 0.15;
}