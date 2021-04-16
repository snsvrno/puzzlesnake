package debug;

class BoundsManager {

	private var debug_graphics : Map<debug.Bounds, h2d.Object> = new Map();

    public function new() {
        debug_graphics = new Map();
    }

    public function add(bounds : debug.Bounds, parent : h2d.Object) {
        debug_graphics.set(bounds, parent);
    }

    public function show(state : Bool) {
        for (k => v in debug_graphics) {
            if (state) v.addChild(k); 
            else v.removeChild(k);
        }
    }
}