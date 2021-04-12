package ui;

class Food extends h2d.Graphics {

    public var width(get, null) : Int;
    private function get_width() : Int {
        return Math.ceil(Settings.UIFOODSIZE + 2 + textValue.textWidth);
    }

    private var textValue : h2d.Text;
    
    /*** the score value multiplier*/
    public var value(default, null) : Int = 1;
    public final variant : Int;

    public function new(variant : Int, parent : h2d.Object) {
        super(parent);

        this.variant = variant;
        var color = Settings.getFoodColor(variant);

        beginFill(color);
        drawRect(-Settings.UIFOODSIZE/2, -Settings.UIFOODSIZE/2, Settings.UIFOODSIZE, Settings.UIFOODSIZE);
        endFill();

        // sets up the text.
        textValue = new h2d.Text(hxd.res.DefaultFont.get(), this);
        updateValue();
        textValue.x = Settings.UIFOODSIZE/2 + 2;
        textValue.y = -textValue.textHeight/2 - 1;
    }

    private function updateValue() {
        textValue.text = 'x$value';
    }

    public function increase() {
        value += 1;
        updateValue();
    }

    public function decrease() {
        value -= 1;
        if (value < 0) value == 0;
        updateValue();
    }
}