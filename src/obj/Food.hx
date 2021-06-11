package obj;

enum FoodType {
	Food; Steroid;
}

class Food extends GridObject {

	public var variant : Int;
	public var value : Int = 1;
	public var foodType : FoodType = Food;

	public function new(?variantupperlimit : Int, ?parent : h2d.Object) {
		super(parent);
		size = 6;
		setVariantRandom(variantupperlimit);
	}

	public function setVariantRandom(?upperlimit : Int) {
		if (upperlimit == null) upperlimit = 6;

		variant = Math.floor(Math.random()*upperlimit);
		fillColor = Settings.getFoodColor(variant);

		updateGraphics();
	}

	public function setVariant(variant : Int) {
		
		this.variant = variant;
		fillColor = Settings.getFoodColor(variant);

		updateGraphics();
	}
}