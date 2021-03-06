package menu.components;

/**
 * a complex menu item that displays some options and allows
 * the user to scroll between them and select a new item.
 */
class MultiItem extends Item {

    private var flex : h2d.Flow;
    private var textObject : h2d.Text;
    private var outline : h2d.filter.Outline;

    private var choices : Array<Choice> = [];
    private var originalPosition : Int = 0;
    private var mouseOverSelected : Null<Int> = null;

    public var selected : Int = 0;

    public var onSelect : Null<(position : Int) -> Void>;

    public function new(?text : String, ?parent : h2d.Object) {
        super(parent);

        // creates a stack for all the items.
        flex = new h2d.Flow(this);
        flex.layout = h2d.Flow.FlowLayout.Horizontal;
        flex.horizontalSpacing = 10;

        textObject = new h2d.Text(hxd.res.DefaultFont.get(), flex);
        textObject.color = h3d.Vector.fromColor(Settings.ui1Color);
        textObject.text = text;

        // creates the outline filter.
        outline = new h2d.filter.Outline(settings.MenuItem.OUTLINE_SIZE, Settings.ui2Color, 1);
        // we just want to put the outline on the title, and not the choices.
        textObject .filter = outline;
    }

    public function addChoice(name : String) : Int {
        var choice = new Choice(name, false);
        choices.push(choice);
        flex.addChild(choice);

        // adds the callback if the base we use the mouse
        choice.onOverCallback = onOverCallbackChild;
        choice.onOutCallback = onOutCallbackChild;
        choice.onActivateCallback = onActivateChild;
        
        // updating the graphics so we don't have to select it
        // to show what is selected the first time
        setSelectedPosition();
        return choices.length - 1;
    }

    override function forceRedraw() {
        super.forceRedraw();
        for (c in choices) c.forceRedraw();
    }

    override public function setSelected() : Bool {
        super.setSelected();
        outline.color = Settings.uiSelectedColor;
        textObject.color = h3d.Vector.fromColor(Settings.ui2Color);
        return true;
    }

    override public function setUnSelected() {
        super.setUnSelected();

        if (mouseOverSelected != null) {
            // returning to the normal selection if nothing
            // was selected.
            selected = mouseOverSelected;
            mouseOverSelected = null;
            setSelectedPosition();
        }

        outline.color = Settings.ui2Color;
        textObject.color = h3d.Vector.fromColor(Settings.ui1Color);
    }

    public function setSelectedPosition(?pos : Int) {
        if (pos != null) selected = pos;

        for (i in 0 ... choices.length) {
            if (i == selected) choices[i].setSelected();
            else choices[i].setUnSelected();
        }
    }

    public function setOriginalSelectedPosition(pos : Int) {
        setSelectedPosition(pos);
        originalPosition = pos;
    }

    override public function moveChoice(direction : Int) {
        if (direction < 0) selected = selected - 1;
        else if (direction > 0) selected = selected + 1;

        if (selected > choices.length-1) selected = choices.length-1;
        else if (selected < 0) selected = 0;

        setSelectedPosition();
        if (onSelect != null) onSelect(selected);
    }

    public function reset() {
        if (selected != originalPosition) onSelect(originalPosition);
    }

    private function onOverCallbackChild(item : Item) {
        setSelected();

        // can totally crash this thing.
        var c = cast(item, Choice);
        var i = choices.indexOf(c);
        
        if (mouseOverSelected == null) { mouseOverSelected = selected; }
        setSelectedPosition(i);
    }

    /**
     * needs to check if the item is selected so that it will
     * not unselect it.
     * @param item 
     */
    private function onOutCallbackChild(item : Item) {

        // can totally crash this thing.
        var c = cast(item, Choice);
        var i = choices.indexOf(c);
        if (selected == i) item.setSelected();
    }

    private function onActivateChild(item : Item) {

        mouseOverSelected = null;
        setSelectedPosition();
        if (onSelect != null) onSelect(selected);
    }
}