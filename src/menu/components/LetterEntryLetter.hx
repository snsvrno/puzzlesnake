package menu.components;

class LetterEntryLetter extends h2d.Object {

    public var color(null, set) : Int;
    private function set_color(newColor : Int) : Int {
        letter.color = h3d.Vector.fromColor(newColor);
        return newColor;
    }

    public var text(get, set) : String; 
    private function get_text() : String return letter.text;
    private function set_text(newText : String) : String return letter.text = newText;

    private var letter : h2d.Text; 
    private var outline : h2d.filter.Outline;

    public function new(?parent : h2d.Object) {
        super(parent);
        letter = new h2d.Text(hxd.res.DefaultFont.get(), this);
        letter.text = "A";

        outline = new h2d.filter.Outline(settings.MenuItem.OUTLINE_SIZE, Settings.ui2Color, 1);
        filter = outline;
    }

    public function setSelected() {
        outline.color = Settings.uiSelectedColor;
        letter.color = h3d.Vector.fromColor(Settings.ui2Color);
    }


    public function setUnselected() {
        outline.color = Settings.ui2Color;
        letter.color = h3d.Vector.fromColor(Settings.ui1Color);
    }

    public function scrollUp() {
        var code = letter.text.charCodeAt(0);
        code += 1;

        if (code > 90) code = 65;
        letter.text = String.fromCharCode(code);
    }

    public function scrollDown() {
        var code = letter.text.charCodeAt(0);
        code -= 1;

        if (code < 65) code = 90;
        letter.text = String.fromCharCode(code);
    }
}