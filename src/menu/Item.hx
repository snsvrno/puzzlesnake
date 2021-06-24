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

    private var interactive : h2d.Interactive;

    // is this item selected by the parent menu.
    private var isSelected : Bool = false;
    public var onOverCallback : Null<(item : Item) -> Void>;
    public var onOutCallback : Null<(item : Item) -> Void>;
    public var onActivateCallback : Null<(item : Item) -> Void>;

    public var onPress : Null<() -> Void>;

    #if debug
    private var interactiveOverlay : h2d.Graphics;
    #end

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

        interactive = new h2d.Interactive(0,0, this);
        interactive.onOver = function (_) {
            setSelected();
            if (onOverCallback != null) onOverCallback(this);
        }
        interactive.onOut = function(_){
            setUnSelected();
            if (onOutCallback != null) onOutCallback(this);
        }
        interactive.onClick = (_) -> activate();

        #if debug
        interactiveOverlay = new h2d.Graphics();
        #end
    }

    override function onAdd() {
        super.onAdd();

        #if debug
        interactiveOverlay.beginFill(0xFF0000,0.2);
        interactiveOverlay.lineStyle(1,0xFF0000,0.5);
        interactiveOverlay.drawRect(0,0, interactive.width, interactive.height);
        #end
    }

    public function forceRedraw() {
        if (isSelected) setSelected();
        else setUnSelected();
    }


    /**
     * sets this item's mouseover / keyover as true. should update
     * shaders / or drawing parameters so that the item is now shown
     * as `over`
     */
    public function setSelected () : Bool { 
        isSelected = true;
        return true;
    };

    /**
     * sets this item's mouseover / keyover as false. should update
     * shaders / or drawing parameters so that this item is now shown
     * as `normal` or `not over`
     */
    public function setUnSelected() : Void { 
        isSelected = false;
    };

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
        if (onActivateCallback != null) onActivateCallback(this); 
    };
}