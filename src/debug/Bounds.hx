package debug;

class Bounds extends h2d.Graphics {

    public var width : Int = 1;
    public var height : Int = 1;
    public var lineColor : Int = 0xFF0000;

    public function updateGraphics() {

        clear();
        lineStyle(2, lineColor);

        // draws the center crosshair.
        moveTo(width/2-10,height/2);
        lineTo(width/2+10,height/2);
        moveTo(width/2,height/2-10);
        lineTo(width/2,height/2+10);

        drawRect(0, 0, width, height);
    }

    override function onAdd() {
        super.onAdd();
        updateGraphics();
    }
}