package obj;

class Food extends GridObject {

	static public var variants : Array<Int> = [
		0x12FF23,
		0xEF5412,
		0x0662FE
	];

	public var variant : Int;

	public function new(?parent : h2d.Object) {
		super(parent);
		setVariant();
		size = 6;

		updateGraphics();
	}

	private function setVariant() {
		variant = Math.floor(Math.random()*variants.length);
		fillColor = variants[variant];
	}
}