package obj;

class Food extends GridObject {

	public var variant : Int;

	public function new(?variantupperlimit : Int, ?parent : h2d.Object) {
		super(parent);
		setVariant(variantupperlimit);
		size = 6;

		updateGraphics();
	}

	public function setVariant(?upperlimit : Int) {
		if (upperlimit == null) upperlimit = 6;

		variant = Math.floor(Math.random()*upperlimit);
		fillColor = Settings.getFoodColor(variant);
	}
}