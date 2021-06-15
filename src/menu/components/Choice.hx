package menu.components;

/**
 * basic component that displays some text.
 */
class Choice extends Item {

    private var outline : h2d.filter.Outline;
    private var textObject : h2d.Text;

    public function new(text : String, ?parent : h2d.Object) {
        super(parent);
        textObject = new h2d.Text(hxd.res.DefaultFont.get(), this);

        textObject.text = text;
        textObject.color = h3d.Vector.fromColor(Settings.ui1Color);

        outline = new h2d.filter.Outline(settings.MenuItem.OUTLINE_SIZE, Settings.ui2Color, 1);
        textObject.filter = outline;
    }

    override public function setSelected() { 
        outline.color = Settings.uiSelectedColor;
        textObject.color = h3d.Vector.fromColor(Settings.ui2Color);
    }

    override public function setUnSelected() { 
        outline.color = Settings.ui2Color;
        textObject.color = h3d.Vector.fromColor(Settings.ui1Color);
    }
}