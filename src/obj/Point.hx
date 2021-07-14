package obj;

/**
 * a class used as a particle / notification that shows when the player
 * gets points!
 */
class Point extends h2d.Object {

    private var duration : Float = 0.33;
    private var timer : Float = 0;
    
    private var scaleStarting : Float = 1.0;
    private var scaleEnding : Float = 5.0;

    private var opacityStarting : Float = 1.0;
    private var opacityEnding : Float = 0.3;

    private var text : h2d.Text;
    
    public function new(display : String, x : Float, y : Float) {
        super();

        this.x = x;
        this.y = y;

        filter = new h2d.filter.Nothing();

        text = new h2d.Text(hxd.res.DefaultFont.get(), this);
        text.text = display;
        text.x = - text.textWidth / 2;
        text.y = - text.textHeight / 2;
    }

    public function update(dt : Float) : Bool {
        timer += dt;

        // if we are longer than the overall duration then we
        // return this so that it will be removed.
        if (timer > duration) { 
            remove();
            return true;
        }

        // update all the stuff.
        var t = timer / duration;
        alpha = opacityStarting + (opacityEnding - opacityStarting) * t;
        text.setScale(scaleStarting + (scaleEnding - scaleStarting) * t);
        text.x = - text.textWidth / 2 * text.scaleX;
        text.y = - text.textHeight / 2 * text.scaleY;

        return false;
    }

}