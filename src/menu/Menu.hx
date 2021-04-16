package menu;

class Menu extends h2d.Object {

    #if debug
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    private var debug_graphics : debug.Bounds;
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #end

    ///////////////////////////////////////////////////////////////////////////
    // PRIVATE MEMBERS

    /*** spacing between items */
    private var itemPadding : Int = settings.Menu.PADDING;

    private var items : Array<Item> = [];
    private var selectedItem : Int = 0;
    private var background : h2d.Graphics;

    ///////////////////////////////////////
    // dimentional information
    /*** the overall defined menu area that can be used, not the physical width of the object. */
    private var width : Int;
    /*** the overall defined menu area that can be used, not the physical height of the object. */
    private var height : Int;
    /*** the overall actual menu area that is used. */
    private var overallHeight : Int;
    /*** the overall actual menu area that is used. */
    private var overallWidth : Int;

    ///////////////////////////////////////////////////////////////////////////
    // INITIALIZATION

    public function new(width : Int, height : Int, ?parent : h2d.Object) {
        super(parent);

        this.width = width;
        this.height = height;

        background = new h2d.Graphics(this);

        #if debug
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        debug_graphics = new debug.Bounds();
        debug_graphics.lineColor = settings.Menu.DEBUG_BOUNDS_COLOR;
        game.Game.debug_graphics.add(debug_graphics, this);
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        #end
    }

    override function onAdd() {
        super.onAdd();

        // ensures we draw this when we add / remove the menu
        drawBackground();

    }

    /**
     * draws the backgroudn overlay that fades out the game so the menu stands out more.
     */
    private function drawBackground() {
        background.clear();
        background.beginFill(settings.Game.BACKGROUND_COLOR, settings.Menu.BACKGROUND_OVERLAY_OPACITY);
        background.drawRect(0, 0, width, height);
        background.endFill();
    }


    ///////////////////////////////////////////////////////////////////////////
    // PRIVATE FUNCTIONS
    
    /**
     * internal function that calculates the placement for all the menu
     * items. is centered in the middle of the defined area.
     */
    private function arrangeItems() {

        var oy = 0;
        for (i in 0 ... items.length) {
            items[i].x = width / 2;
            items[i].y = height / 2 - overallHeight/2 + oy + items[i].height/2;

            oy = items[i].height + itemPadding;
        }

        #if debug
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // updating the position of the overlay since it has now changed
        debug_graphics.x = width / 2 - overallWidth / 2;
        debug_graphics.y = height / 2 - overallHeight / 2;
        debug_graphics.width = overallWidth;
        debug_graphics.height = overallHeight;
        // updates the drawing of the overlay.
        debug_graphics.updateGraphics();
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        #end
    }

    private function previousItem() {
        selectedItem -= 1;

        if (selectedItem < 0) selectedItem = items.length-1;

        selectItem(selectedItem);
    }

    private function nextItem() {
        selectedItem += 1;

        if (selectedItem > items.length - 1) selectedItem = 0;

        selectItem(selectedItem);
    }

    private function activateItem() {
        items[selectedItem].activate();
    }


    ///////////////////////////////////////////////////////////////////////////
    // PUBLIC FUNCTIONS

    /**
     * selects the request item position. has error checking
     * so that it will only attempt to select an actual item. 
     * will default to the first item if there is an error.
     * @param pos 
     */
    public function selectItem(?pos : Int = 0) {
        // makes sure we don't give it a number that is
        // out of the bounds.
        if (pos < 0 || pos > items.length) pos = 0;

        // selects the chosen one.
        items[pos].setSelected();

        // makes sure that all the other items are deselected.
        for (i in 0 ... items.length) if (i != pos) items[i].setUnSelected();

        selectedItem = pos;
    }

    public function addItem(item : Item) {
        items.push(item);
        addChild(item);

        // calculates the overall height and width so we know where to start drawing things.
        overallHeight = (items.length - 1) * itemPadding;
        overallWidth = 0;
        for (i in items) { 
            overallHeight += i.height;
            if (overallWidth < i.width) overallWidth = i.width;
        }

        arrangeItems();
    }

    public function keypressed(keycode : Int) {

        if (Controls.is("confirm", keycode)) activateItem();
        if (Controls.is("cancel", keycode)) game.Game.shiftMenu();
		if (Controls.is("up", keycode)) previousItem();
		if (Controls.is("down", keycode)) nextItem();

		//if (Controls.is("left", keycode)) if (movingDirection == Up || direction == Down) direction = Left;
		//if (Controls.is("right", keycode)) if (movingDirection == Up || direction == Down) direction = Right;
    }
}