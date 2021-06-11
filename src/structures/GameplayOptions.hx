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

	/*** modifier just for moving */
	tickMovement : Float,

	/*** the weight of the players tails when generating food */
	foodGenPlayerCut : Float,
	
	/***  the weight of the standard generation when generation food */
	foodGenBaseCut : Float,
};