package obj;

class Tail extends GridObject {

	public final variant : Int;

	public function new(food : Food, ?parent : h2d.Object) {
		super(parent);

		variant = food.variant;
		fillColor = food.fillColor;
		updateGraphics();
	}

	override function forceRedraw() {
		// updates the color
		fillColor = Settings.getFoodColor(variant);
		// redraws it
		super.forceRedraw();
	}
}