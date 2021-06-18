package menu;

class Menu extends h2d.Object {

    private var items : Array<Item> = [];
    private var selectedItem : Int = 0;

    private var flex : h2d.Flow;
    private var background : h2d.Graphics;

    private var width : Int;
    private var height : Int;

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
    }

    public function selectItem(?pos : Int = 0) {
        // makes sure we don't give it a number that is
        // out of the bounds.
        if (pos < 0 || pos > items.length) pos = 0;

        items[pos].setSelected();

        // makes sure that all the other items are deselected.
        for (i in 0 ... items.length) if (i != pos) items[i].setUnSelected();

        selectedItem = pos;
    }

    public function keypressed(keycode : Int) {

        if (Controls.is("confirm", keycode)) activateItem();
        if (Controls.is("cancel", keycode)) game.Game.shiftMenu();
		if (Controls.is("up", keycode)) previousItem();
		if (Controls.is("down", keycode)) nextItem();

		if (Controls.is("left", keycode)) items[selectedItem].moveChoice(-1);
		if (Controls.is("right", keycode)) items[selectedItem].moveChoice(1);
        
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
}