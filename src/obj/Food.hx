package obj;

class Food extends GridObject {

	static public var variants : Array<Int> = [
		0xEF5412, // red
		0xf5e400, // yellow
		0x0662FE, // blue
		0x12FF23, // green
		0xc840f5, // violet
		0xcc7b02, // orange
	];

	public var variant : Int;

	public function new(?variantupperlimit : Int, ?parent : h2d.Object) {
		super(parent);
		setVariant(variantupperlimit);
		size = 6;

		updateGraphics();
	}

	public function setVariant(?upperlimit : Int) {
		if (upperlimit == null) upperlimit = variants.length;
		variant = Math.floor(Math.random()*upperlimit);
		fillColor = variants[variant];
	}
}