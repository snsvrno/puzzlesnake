package menu.components;

/**
 * basic component that displays some text, not interactive.
 */
class Text extends Item {

    private var textObject : h2d.Text;

    public function new(text : String, ?enableOutline : Bool = true, ?parent : h2d.Object) {
        super(parent);
        textObject = new h2d.Text(hxd.res.DefaultFont.get(), this);

        textObject.text = text;
        textObject.color = h3d.Vector.fromColor(Settings.ui1Color);
    }

    public function setText(text : String) {
        textObject.text = text;
    }

    override public function setSelected() : Bool { return false; }

    override public function setUnSelected() { }
}