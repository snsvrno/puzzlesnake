package obj;

/**
 * a subfood that makes the walls eatable
 */
class Steroid extends Food {

    private var startingColor : Int;
    private var blinkFrame : Bool = false;
    private var life : Int;
    
    /*** the divisor in the sin(x/b) equation for determining the blink */
    private var sinB : Int;
    private var sinX : Int = 0;

    private var segments = settings.Game.STEROID_SEGMENTS;
    private var transformationTimer : Float = 0;

	public function new(variant : Int, ?life : Int, ?parent : h2d.Object) {
		super(parent);
        this.variant = variant;
        foodType = Steroid;

        if (life != null) this.life = life;
        else this.life = settings.Game.STEROID_LIFE;

		startingColor = fillColor = Settings.getFoodColor(variant);

        // we set sinB per the description in turnTick();
        sinB = Math.floor(settings.Game.STEROID_LIFE / 2);

		updateGraphics();
	}

    override function update(dt : Float) {
        if (life == 0) {

            // the transformation animation

            transformationTimer += dt;

            // calculates the new number of segments. may not actually change
            // from the last frame.
            var removal = Math.floor(transformationTimer * settings.Game.STEROID_TRANSFORM_SPEED);
            var newSegments  = settings.Game.STEROID_SEGMENTS - removal;

            // updates the rotation
            rotation = transformationTimer * settings.Game.STEROID_TRANSFORM_ROTATION_SPEED;

            // updates some scaling action
            var maxTime = (settings.Game.STEROID_SEGMENTS / settings.Game.STEROID_TRANSFORM_SPEED);
            var growTime = maxTime - settings.Game.STEROID_TRANSFORM_SHRINK_SPEED;
            
            // calculates the new scale.
            var newScale : Float = if (transformationTimer < growTime) {
                1 + transformationTimer / maxTime * settings.Game.STEROID_TRANSFORM_SCALE;
            } else {
                1 + (maxTime - transformationTimer) / maxTime + settings.Game.STEROID_TRANSFORM_SCALE;
            };

            this.setScale(newScale);

            // if we need to change the segments
            if (newSegments != segments) {
                segments = newSegments;

                if (segments <= 4) { convertToFood(); return; }
                updateGraphics();
            }
        }
    }

    override function turnTick() {
        // we stop doing all this stuff if we are at the end of life.
        // we shouldn't do it, but we need to do the special graphics where the
        // thing does the transformation.
        if (life <= 0) return;

        // doing some "stupid?" math to make it blink slower and then faster.
        // so i want it to blink slower and then faster until it stop blinking, and that is when it is done.
        // we will use sin (x/b) to determine if we should blink, and only blink when that equals 1.
        // first we start off with `b = life/2` with x being the current tick count. then 
        // `b` is the remaining life / 2 until the life is zero and then it is converted into
        // a food.
        var doBlink : Bool = {
            sinX += 1;
            var value = Math.sin(sinX * Math.PI / sinB / 2);
            if (value > 0.99) true; 
            else false;
        }

        if (doBlink) {
            
            // update the color. if we are going to blink
            if (blinkFrame) fillColor = startingColor;
            else fillColor = 0xFFFFFF;
            blinkFrame = !blinkFrame;

            // recalculate the 
            sinX = 0;
            sinB = Math.floor(life/2);
            
            // update the graphics so we see the update / the change.
            updateGraphics();
        }


        // reduce the life and check if we should convert this to a normal food because we didn't get to it in time.
        life -= 1;
    }

	override private function updateGraphics() {
		clear();

		beginFill();
		if (outlineSize > 0) {
			setColor(outlineColor);
			drawRect(-size/2, -size/2, size, size);
		}
		setColor(fillColor);
		drawCircle(0, 0, size/2, segments);
        // drawRect(-size/2 + outlineSize, -size/2 + outlineSize, size - 2*outlineSize, size - 2*outlineSize);
		endFill();
	}

    /**
     * converts this object into a food object.
     */
    private function convertToFood() {
        var food = new Food();

        // manually gets the color and variant the same.
        food.variant = variant;
        food.fillColor = startingColor;
        food.updateGraphics();

        // sets the value
        food.value = value;

        // replaces the item in the container
        var fc = cast(parent, Container<Dynamic>);
        fc.swapObj(this, food);
    }
}