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
}