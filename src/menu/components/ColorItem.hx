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

    private var colors : Array<ColorTile> = [];

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

    override public function setSelected() { 
        super.setSelected();
        outline.color = Settings.uiSelectedColor;
        textObject.color = h3d.Vector.fromColor(Settings.ui2Color);
    }

    override public function setUnSelected() { 
        super.setUnSelected();
        outline.color = Settings.ui2Color;
        textObject.color = h3d.Vector.fromColor(Settings.ui1Color);
    }

    public function setSelectedPosition(?pos : Int) {
        if (pos != null) selected = pos;

        for (i in 0 ... colors.length) {
            if (i < selected) colors[i].setSelected();
            else if (i == selected) colors[i].setHighlighted();
            else colors[i].setUnselected();
        }
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

        // adds the object to the flex so we display it.
        flex.addChild(object);

        // centers the flex inside of this item container.
        //flex.x = -flex.outerWidth / 2;
    }

    override public function moveChoice(direction : Int) {
        if (direction < 0) selected = selected - 1;
        else if (direction > 0) selected = selected + 1;

        if (selected > colors.length-1) selected = colors.length-1;
        else if (selected < 0) selected = 0;

        setSelectedPosition();
    }
}