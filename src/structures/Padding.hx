package structures;

abstract Padding(Array<Int>) {

	public var left(get, never) : Int;
	private function get_left() : Int return this[0];

	public var top(get, never) : Int;
	private function get_top() : Int return this[1];

	public var right(get, never) : Int;
	private function get_right() : Int return this[2];

	public var bottom(get, never) : Int;
	private function get_bottom() : Int return this[3];

	public function new(?left : Int, ?top : Int, ?right : Int, ?bottom : Int) {
		if (left == null) left = 0;

		this = new Array<Int>();
		this.push(left);

		if (top != null) this.push(top)
		else this.push(left);

		if (right != null) this.push(right);
		else this.push(left);

		if (bottom != null) this.push(bottom);
		else if (top != null) this.push(top);
		else this.push(left);
	}
}