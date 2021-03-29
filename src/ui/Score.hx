package ui;

class Score extends h2d.Object {
	
	public var value(default, set) : Int = 0;
	private var text : h2d.Text;

	public function new(parent : h2d.Object) {
		super(parent);
		text = new h2d.Text(hxd.res.DefaultFont.get(), this);
		updateDisplay();
	}

	private function updateDisplay() {
		text.text = '$value';
		text.x = -1 * text.textWidth;
		text.y = -1 * text.textHeight/2;
	}

	private function set_value(number : Int) : Int {
		value = number;
		updateDisplay();
		return value;
	}
}