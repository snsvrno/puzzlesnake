class Tail extends GridObject {

	public final variant : Int;

	public function new(food : Food, ?parent : h2d.Object) {
		super(parent);

		variant = food.variant;
		fillColor = food.fillColor;
		updateGraphics();
	}

	public function setWall() {
		outlineColor = fillColor;
		fillColor = 0x222222;
		outlineSize = 4;
		updateGraphics();
	}
}