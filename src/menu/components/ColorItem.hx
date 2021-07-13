package menu.components;

/**
 * a complex menu item that displays a number of color tiles. acts like a 
 * volume bar, going left will decrease the number of tiles selected and
 * going right will increase it. there is no "overflow" or "wrap"
 * 
 * use the 'selected' member to find out whick color was selected.
 */
class ColorItem extends Item {

    private var flex : h2d.Flow;
    private var textObject : h2d.Text;
    private var outline : h2d.filter.Outline;

    public var onChoice : Null<(choice : Int) -> Void>;

    private var colors : Array<ColorTile> = [];

    /**
     * a check to see if we got to this point because we 
     * used a mouse or the keys.
     * 
     * checking this because if we use the mouse we need
     * to click in order to set that color. if we use the
     * keys then we set the color just by scrolling.
     */
    private var originalOverSelected : Null<Int> = null;

    public var selected : Int = 0;

    public var colorSize(default, set) : Int = 16;
    private function set_colorSize(size : Int) : Int {
        var colorSize = size;

        // updates the graphics so that all the existing
        // color tiles are now the new set size.
        // this way we can set it where ever and everything
        // should update.
        for (i in 0 ... colors.length) colors[i].drawColor(colorSize);

        return colorSize;
    }

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
        filter = outline;
    }

    override public function setSelected() : Bool { 
        super.setSelected();
        outline.color = Settings.uiSelectedColor;
        textObject.color = h3d.Vector.fromColor(Settings.ui2Color);
        return true;
    }

    override public function setUnSelected() { 
        super.setUnSelected();
        outline.color = Settings.ui2Color;
        textObject.color = h3d.Vector.fromColor(Settings.ui1Color);

        // checks if just moused over stuff with the mouse, if we did
        // then we must revert it
        if (originalOverSelected != null) {
            setSelectedPosition(originalOverSelected);
            originalOverSelected == null;
        }
    }

    public function setSelectedPosition(?pos : Int) {
        if (pos != null) selected = pos;

        for (i in 0 ... colors.length) {
            if (i < selected) colors[i].setSelected();
            else if (i == selected) colors[i].setHighlighted();
            else colors[i].setUnselected();
        }

        if (onChoice != null) onChoice(selected);
    }

    /**
     * sets the colors overriding whatever the existing colors are.
     * @param array 
     */
    public function setColors(newColors : Array<Int>) {

        // removes the existing colors.
        while (colors.length > 0) {
            var color = colors.pop();
            flex.removeChild(color);
            color.remove();
        }

        // creates new objects for each color
        // and then adds it to the array.
        for (i in 0 ... newColors.length) {
            addColor(newColors[i]);
        }
    }

    public function addColor(color : Int) {
        var object = new ColorTile(color);

        colors.push(object);

        object.drawColor(colorSize);
        object.onOverCallback = onChildOverCallback;

        // adds the object to the flex so we display it.
        flex.addChild(object);

        // centers the flex inside of this item container.
        //flex.x = -flex.outerWidth / 2;

        interactive.width = flex.innerWidth;
        interactive.height = flex.innerHeight;
    }

    override public function moveChoice(direction : Int) {

        if (originalOverSelected != null) {
            // we check if we were moving around on the mouse, because if we were
            // then we ignore the selected position and revert it back to the 
            // position it was before we started moving the mouse.
            selected = originalOverSelected;
            originalOverSelected == null;
        }

        if (direction < 0) selected = selected - 1;
        else if (direction > 0) selected = selected + 1;

        if (selected > colors.length-1) selected = colors.length-1;
        else if (selected < 0) selected = 0;

        setSelectedPosition();
    }

    private function onChildOverCallback(item : ColorTile) {
        if (originalOverSelected == null) originalOverSelected = selected;
        var i = colors.indexOf(item);
        setSelectedPosition(i);
    }
}