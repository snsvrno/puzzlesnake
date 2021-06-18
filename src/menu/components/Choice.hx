package menu.components;

/**
 * basic component that displays some text.
 */
class Choice extends Item {

    private var outline : h2d.filter.Outline;
    private var textObject : h2d.Text;
    private var inverted : Bool = false;

    public function new(text : String, ?enableOutline : Bool = true, ?parent : h2d.Object) {
        super(parent);
        textObject = new h2d.Text(hxd.res.DefaultFont.get(), this);

        textObject.text = text;
        textObject.color = h3d.Vector.fromColor(Settings.ui1Color);

        outline = new h2d.filter.Outline(settings.MenuItem.OUTLINE_SIZE, Settings.ui2Color, 1);
        if (enableOutline) textObject.filter = outline;
        else inverted = true;

        interactive.width = textObject.textWidth;
        interactive.height = textObject.textHeight;
    }

    

    public function setTextColor(color : Int) {
        textObject.color = h3d.Vector.fromColor(color);
    }

    override public function setSelected() { 
        super.setSelected();
        outline.color = Settings.uiSelectedColor;
        if (inverted) textObject.color = h3d.Vector.fromColor(Settings.ui1Color);
        else textObject.color = h3d.Vector.fromColor(Settings.ui2Color);
    }

    override public function setUnSelected() { 
        super.setUnSelected();
        outline.color = Settings.ui2Color;
        if (inverted) textObject.color = h3d.Vector.fromColor(Settings.ui2Color);
        else textObject.color = h3d.Vector.fromColor(Settings.ui1Color);
    }
}