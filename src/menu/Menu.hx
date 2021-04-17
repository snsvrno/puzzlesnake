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

    private var title : Null<h2d.Object>;
    private var description : Null<h2d.Text>;
    

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

    public function new(width : Int, height : Int, ?title : String, ?parent : h2d.Object) {
        super(parent);

        this.width = width;
        this.height = height;

        background = new h2d.Graphics(this);

        if (title != null) {
            this.title = new h2d.Object(this);

            // the text, aligning middle, bottom.
            var titleObject = new h2d.Text(hxd.res.DefaultFont.get(), this.title);
            titleObject.text = title;
            titleObject.y = -titleObject.textHeight * titleObject.scaleY - 2;
            titleObject.x = -titleObject.textWidth/2 * titleObject.scaleX;

            var decorations = new h2d.Graphics(this.title);
            var lineHalfWidth : Float = titleObject.textWidth / 2 * titleObject.scaleX * 1.2;
            decorations.lineStyle(1, 0xFFFFFF);
            decorations.moveTo(-lineHalfWidth, 0);
            decorations.lineTo(lineHalfWidth, 0);
        }

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
        drawsGraphics();

    }

    ///////////////////////////////////////////////////////////////////////////
    // PRIVATE FUNCTIONS

    /**
     * draws the h2d.graphics overlay that fades out the game so the menu stands out more.
     */
    private function drawsGraphics() {

        // draws the background
        background.clear();
        background.beginFill(settings.Game.BACKGROUND_COLOR, settings.Menu.BACKGROUND_OVERLAY_OPACITY);
        background.drawRect(0, 0, width, height);
        background.endFill();

        // draws the title decoration if exists.
        if (title != null) {

        }
    }
    
    /**
     * internal function that calculates the placement for all the menu
     * items. is centered in the middle of the defined area.
     */
    private function arrangeItems() {

        var oy = 0;

        // places all the items
        for (i in 0 ... items.length) {
            items[i].x = width / 2;
            items[i].y = height / 2 - overallHeight/2 + oy + items[i].height/2;
            oy += items[i].height + itemPadding;
        }

        // places the title so it is right above the first element.
        if (title != null) {
            title.x = items[0].x;
            title.y = (items[0].y - items[0].height / 2) - settings.Menu.TITLE_SPACING;

            // if we have a description we need to move the title up
            // to account for that.
            if (description != null) {
                title.y -= description.textHeight * description.scaleY;
            }
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

		if (Controls.is("left", keycode)) items[selectedItem].moveChoice(-1);
		if (Controls.is("right", keycode)) items[selectedItem].moveChoice(1);
    }

    public function setDescription(descriptionText : String) {
        // check since we are going to add this description object to the title object
        // so it must be created.
        if (title == null) throw("can't add a drescription to a menu is there isn't a title");

        if (description == null) {
            description = new h2d.Text(hxd.res.DefaultFont.get(), title);
            description.maxWidth = width * settings.Menu.DESCRIPTION_MAX_WIDTH_MOD;
            description.textAlign = Center;
            description.x = -description.maxWidth/2;
        } 

        description.text = descriptionText;
    }
}