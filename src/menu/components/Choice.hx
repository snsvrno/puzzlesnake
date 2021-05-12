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

        outline = new h2d.filter.Outline(settings.MenuItem.OUTLINE_SIZE, settings.MenuItem.OUTLINE_OVER_COLOR, 1);
        textObject.filter = outline;
    }

    override public function setSelected() outline.color = settings.MenuItem.OUTLINE_OVER_COLOR;
    override public function setUnSelected() outline.color = settings.MenuItem.OUTLINE_COLOR;
}