class Food extends GridObject {

	public function new(?parent : h2d.Object) {
		super(parent);

		fillColor = 0x12FF23;
		size = 6;

		updateGraphics();
	}
}