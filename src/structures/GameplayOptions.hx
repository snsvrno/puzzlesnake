package structures;

typedef GameplayOptions = {
	/*** how many blocks of the same color are required to make a wall. */
	wallLength : Int,
	
	/*** how many food colors are there, */
	colors : Int,

	/*** what is the base speed for the turn / tick */
	startingTickSpeed : Float,

	/*** tick speed modifier when eating food. */
	tickEatFood : Float,

	/*** tick speed modifier when making a wall. */
	tickMakeWall : Float,

	/*** how many foods should be on the board at once. */
	foodLimit : Int,
};