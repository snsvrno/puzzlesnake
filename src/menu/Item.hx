package menu;

class Item extends h2d.Object {

    #if debug
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    private var debug_graphics : debug.Bounds;
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #end

    ///////////////////////////////////////////////////////////////////////////
    // PUBLIC MEMBERS
    public var height : Int;
    public var width : Int;

    public function new(?parent : h2d.Object) {
        super(parent);

        #if debug
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // creates a bounding box around the item
        debug_graphics = new debug.Bounds();
        debug_graphics.lineColor = settings.MenuItem.DEBUG_BOUNDS_COLOR;
        game.Game.debug_graphics.add(debug_graphics, this);
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        #end
    }

    public var onPress : Null<() -> Void>;

    /**
     * sets this item's mouseover / keyover as true. should update
     * shaders / or drawing parameters so that the item is now shown
     * as `over`
     */
    public function setSelected (): Void { };

    /**
     * sets this item's mouseover / keyover as false. should update
     * shaders / or drawing parameters so that this item is now shown
     * as `normal` or `not over`
     */
    public function setUnSelected() : Void { };

    /**
     * moves the item choice left and right based on the input direction. should
     * only receive `1` and `-1` but you shouldn't assume that. check for sign only.
     * @param direction 
     */
    public function moveChoice(direction : Int) : Void { };

    /**
     * what happens if the user clicks `enter` on this item. is there some kind of action
     * that should be executed.
     */
    public function activate() : Void {
        if (onPress != null) onPress(); 
    };
}