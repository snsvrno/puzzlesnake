package menu;

class Menu extends h2d.Object {

    private var items : Array<Item> = [];
    private var selectedItem : Int = 0;

    private var flex : h2d.Flow;
    private var background : h2d.Graphics;

    private var width : Int;
    private var height : Int;

    /**
     * if this menu can change the selected item by using the up and down commands.
     */
    public var verticalScroll : Bool = true;

    public function new(width : Int, height : Int, ?title : String, ?parent : h2d.Object) {
        super(parent);

        this.width = width;
        this.height = height;

        background = new h2d.Graphics(this);

        flex = new h2d.Flow(this);
        flex.layout = Vertical;
        flex.verticalSpacing = settings.Menu.PADDING;
        flex.verticalAlign = Middle;
        flex.horizontalAlign = Middle;

        var cornerText = new h2d.Text(hxd.res.DefaultFont.get(), this);
        cornerText.text = game.Game.version;
        #if debug
        cornerText.text += ' (${game.Game.buildInformation})';
        #end
        cornerText.textAlign = Right;
        cornerText.x = width - 10;
        cornerText.y = height - 10;

        if (title != null) {
            var titleObject = new h2d.Text(hxd.res.DefaultFont.get(), flex);
            titleObject.color = h3d.Vector.fromColor(Settings.ui1Color);
            titleObject.text = title;

            var spacer = new h2d.Graphics(flex);
            spacer.lineStyle(1,Settings.ui1Color);
            spacer.moveTo(-100,0);
            spacer.lineTo(100,0);
        }
    }

    public function forceRedraw() {
        for (i in items) i.forceRedraw();
    }

    override function onAdd() {
        super.onAdd();

        // ensures we draw this when we add / remove the menu
        drawsGraphics();

    }
    private function drawsGraphics() {

        // draws the background
        background.clear();
        background.beginFill(Settings.backgroundColor, settings.Menu.BACKGROUND_OVERLAY_OPACITY);
        background.drawRect(0, 0, width, height);
        background.endFill();
    }
    
    
    public function setDescription(description : String) {
        
    }

    public function addItem(item : Item) {
        items.push(item);
        flex.addChild(item);

        // update the position of the entire flex
        // * adds the `Math.floor` because we were getting weird pixel drawing
        //   issues where it would be distorted because it was drawing on sub-pixels.
        flex.x = Math.floor(width / 2 - flex.outerWidth / 2);
        flex.y = Math.floor(height / 2 - flex.outerHeight / 2);

        item.onOverCallback = onOverCallback;
    }

    /**
     * will attempt to select the item at the position. it will return if the item
     * was selected or not (if the item is selectable)
     * @param pos 
     * @return Bool
     */
    public function selectItem(?pos : Int = 0) : Bool {
        // makes sure we don't give it a number that is
        // out of the bounds.
        if (pos < 0 || pos > items.length) pos = 0;

        var selectable = items[pos].setSelected();

        // makes sure that all the other items are deselected.
        for (i in 0 ... items.length) if (i != pos) items[i].setUnSelected();

        selectedItem = pos;

        return selectable;
    }

    public function keypressed(keycode : Int) {

        if (Controls.is("confirm", keycode)) activateItem();
        if (Controls.is("cancel", keycode)) game.Game.shiftMenu();

        // SCROLLING
        // if vertical scroll is enabled then we will scroll betwen items, otherwise
        // we will pass that through to the selected item.
		if (verticalScroll && Controls.is("up", keycode)) previousItem();
        else if (Controls.is("up", keycode)) items[selectedItem].verticalScroll(-1);
        // 
		if (verticalScroll && Controls.is("down", keycode)) nextItem();
        else if (Controls.is("down", keycode)) items[selectedItem].verticalScroll(1);

        // selecting the choice, is always passed through to the selected item.
		if (Controls.is("left", keycode)) items[selectedItem].moveChoice(-1);
		if (Controls.is("right", keycode)) items[selectedItem].moveChoice(1);
        
    }

    private function previousItem() {
        selectedItem -= 1;

        if (selectedItem < 0) selectedItem = items.length-1;

        if (selectItem(selectedItem) == false) previousItem();
    }

    private function nextItem() {
        selectedItem += 1;

        if (selectedItem > items.length - 1) selectedItem = 0;

        if (selectItem(selectedItem) == false) nextItem();
    }

    private function activateItem() {
        items[selectedItem].activate();
    }

    /**
     * a callback function that we can use to
     * unselect menu items whenver another gets selected
     * if we are doing it from a mouse or touch press.
     * @param item 
     */
    private function onOverCallback(item : Item) {
        for (i in 0 ... items.length) {
            if (items[i] != item) { 
                // unselect all the other items just in case.
                items[i].setUnSelected();
            } else {
                // we set the last selected item as this item
                // so if we switch back to gamepad / keyboard it
                // will work.
                selectedItem = i;
            }
        }
    }
}