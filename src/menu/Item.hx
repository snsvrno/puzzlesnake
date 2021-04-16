package menu;

class Item extends h2d.Object {

    #if debug
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    private var debug_graphics : debug.Bounds;
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #end
    
    ///////////////////////////////////////////////////////////////////////////
    // PRIVATE MEMBERS
    private var textObject : h2d.Text;
    private var outline : h2d.filter.Outline;

    ///////////////////////////////////////////////////////////////////////////
    // PUBLIC MEMBERS
    public var height : Int;
    public var width : Int;

    public var onPress : Null<() -> Void>;

    public function new(?text : String, ?parent : h2d.Object) {
        super(parent);

        // creates the text object.
        textObject = new h2d.Text(hxd.res.DefaultFont.get(), this);
        textObject.setScale(2);

        // creates the outline filter.
        outline = new h2d.filter.Outline(settings.MenuItem.OUTLINE_SIZE, settings.MenuItem.OUTLINE_OVER_COLOR, 1);
        textObject.filter = outline;

        #if debug
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // creates a bounding box around the item
        debug_graphics = new debug.Bounds();
        debug_graphics.lineColor = settings.MenuItem.DEBUG_BOUNDS_COLOR;
        game.Game.debug_graphics.add(debug_graphics, this);
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        #end

        if (text != null) setText(text);
        else setText("<item>");
    }

    /**
     * sets the display text for the item.
     * @param text 
     */
    public function setText(text : String) {
        textObject.text = text;

        textObject.x = -textObject.textWidth / 2 * textObject.scaleX;
        textObject.y = -textObject.textHeight / 2 * textObject.scaleY;

        height = Math.ceil(textObject.textHeight * textObject.scaleY);
        width = Math.ceil(textObject.textWidth * textObject.scaleX);

        #if debug
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        debug_graphics.x = -width/2;
        debug_graphics.y = -height/2;
        debug_graphics.width = width;
        debug_graphics.height = height;
        debug_graphics.updateGraphics();
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        #end
    }

    public function activate() {
        if (onPress != null) onPress();
    }

    public function setSelected() outline.color = settings.MenuItem.OUTLINE_OVER_COLOR;
    public function setUnSelected() outline.color = settings.MenuItem.OUTLINE_COLOR;

}