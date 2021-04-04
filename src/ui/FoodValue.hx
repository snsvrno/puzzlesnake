package ui;

class FoodValue extends h2d.Graphics {

	public final variant : Int;
	private final fillColor : Int;
	private final size : Int;

	private var text : h2d.Text;
	public var value(default, null) : Int = 1;

	public function new(variant : Int, parent : h2d.Object) {
		super(parent);

		this.variant = variant;
		fillColor = Settings.getFoodColor(variant);
		size = 6;

		text = new h2d.Text(hxd.res.DefaultFont.get(), this);

		beginFill(fillColor);
		drawRect(-size/2,-size/2,size, size);
		endFill();

		updateValue();

	}

	private function updateValue() {
		text.text = 'x$value';
		text.x = size/2 + 2;
		text.y = -text.textHeight/2 - 1;
	}

	public function increase() {
		value += 1;
		updateValue();
	}

	public function decrease() {
		value -= 1;
		if (value < 1) value == 1;
		updateValue();
	}

	public function reset() {
		value = 1;
		updateValue();
	}
}