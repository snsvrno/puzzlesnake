package menu.components;

class LetterEntry extends Item {

    private var flex : h2d.Flow;
    private var letterFlex : h2d.Flow;
    private var textObject : h2d.Text;
    private var outline : h2d.filter.Outline;

    private var letters : Array<h2d.Text>;

    private var selectedCharacter : Int = 0;

    public function new(title : String, letters : Int, ?parent : h2d.Object) {
        super(parent);

        // creates a stack for all the items.
        flex = new h2d.Flow(this);
        flex.layout = h2d.Flow.FlowLayout.Horizontal;
        flex.horizontalSpacing = 50;

        textObject = new h2d.Text(hxd.res.DefaultFont.get(), flex);
        textObject.color = h3d.Vector.fromColor(Settings.ui1Color);
        textObject.text = title;

        letterFlex = new h2d.Flow(flex);
        letterFlex.layout = h2d.Flow.FlowLayout.Horizontal;
        flex.horizontalSpacing = 6;

        this.letters = [];

        for (_ in 0 ... letters) {
            var letter = new h2d.Text(hxd.res.DefaultFont.get(), letterFlex);
            letter.color = h3d.Vector.fromColor(Settings.ui1Color);
            letter.text = "A";

            this.letters.push(letter);
        }

        // creates the outline filter.
        outline = new h2d.filter.Outline(settings.MenuItem.OUTLINE_SIZE, Settings.ui2Color, 1);
        textObject.filter = outline;
    }

    public function getText() : String {
        var text : String = "";
        for (i in letters) text += i.text;
        return text;
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
    }
}