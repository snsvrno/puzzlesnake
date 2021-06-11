package obj;

/**
 * A generic container object for `GridObject` that combines both
 * the `Array<T>` and the `h2d.Object` management.
 */
class Container<T : obj.GridObject> extends h2d.Object {

    private var items : Array<T> = [];

    public var length(get, null) : Int;
    private function get_length() : Int return items.length;

    public function new(?parent : h2d.Object) {
        super(parent);
    }

    public function addObj(t : T) {
        if (!items.contains(t)) {
            items.push(t);
            addChild(t);
        }
    }

    public function pop() : T {
        var t = items.pop();
        t.remove();
        return t;
    }

    public function iter() : Array<T> {
        return items;
    }

    public function removeObj(t : T) {
        t.remove();
        items.remove(t);
    }

    public function swapObj(ot : T, nt : T) {
        removeObj(ot);
        addObj(nt);
        nt.setGridPosition(ot.getGridPosition());
    }

}