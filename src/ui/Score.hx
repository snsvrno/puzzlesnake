package ui;

class Score extends h2d.Object {
    public var value(default, set) : Int = 0;
    private function set_value(newValue : Int) : Int {
        value = newValue;
        updateDisplay();
        return value;
    }

    private var textObject : h2d.Text;

    public function new(parent : h2d.Object) {
        super(parent);
        textObject = new h2d.Text(hxd.res.DefaultFont.get(), this);
        updateDisplay();
    }

    private function updateDisplay() {
        textObject.text = '$value';
        textObject.x = -1 * textObject.textWidth;
        textObject.y = -1 * textObject.textHeight/2;
    }
}