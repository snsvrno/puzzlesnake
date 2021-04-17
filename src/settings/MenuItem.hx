package settings;

class MenuItem {

	/*** the color of when a particular menu item is selected*/
	inline static public var OUTLINE_OVER_COLOR : Int = 0x666666;
	/*** the color of when a particular menu item is selected*/
	inline static public var OUTLINE_COLOR : Int = settings.Game.BACKGROUND_COLOR;
	/*** the color of when a particular menu item is selected*/
	inline static public var OUTLINE_SIZE : Int = 1;

	/*** the padding to use between the individual choices */
	inline static public var CHOICE_PADDING : Int = 6;
	/*** the padding to use between the item and the choice */
	inline static public var ITEM_CHOICE_PADDING : Int = 24;
	/*** the scale for the selected choice */
	inline static public var SELECTED_CHOICE_SIZE : Float = 2;
	

    ///////////////////////////////////////////////////////////////
    // DEBUG SETTINGS

    /*** the color for the debug bounds overlay */
    inline static public var DEBUG_BOUNDS_COLOR : Int = 0x23FF12;
}