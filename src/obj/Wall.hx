package obj;

class Wall extends GridObject {

	public final variant : Int;
    public final value : Int = 1;
    public var eatable(default, null) : Bool = false;
    
    private var originalColor : Int;

    // for the blinking when its eatable
    private var countdown : Int = 0;
    private var sinB : Int;
    private var sinX : Int = 0;
    private var blinkFrame : Bool = false;

	public function new(variant : Int, ?parent : h2d.Object) {
		super(parent);

        this.variant = variant;
        outlineColor = originalColor = Settings.getFoodColor(variant);

        fillColor = settings.Game.WALL_COLOR;
        outlineSize = 4;

		updateGraphics();
	}

    public function setEatable() {
        eatable = true;
        countdown = settings.Game.STEROID_LASTING_TIME;
        outlineColor = settings.Game.WALL_COLOR;
        fillColor = originalColor;
        sinB = Math.floor(settings.Game.STEROID_LASTING_TIME / 2);

		updateGraphics();
    }

    override function turnTick() {
        if (eatable) {

            countdown -= 1;
            
            if (countdown <= 0) {
                eatable = false;
                outlineColor = originalColor;
                fillColor = settings.Game.WALL_COLOR;
		        updateGraphics();
                return;
            }

            // does a timer so we can see when it might be dangerous to try and 
            // eat the food

            var doBlink : Bool = {
                sinX += 1;
                var value = Math.sin(sinX * Math.PI / sinB / 2);
                if (value > 0.99) true; 
                else false;
            }

            if (doBlink) {
                
                // update the color. if we are going to blink
                if (blinkFrame) outlineColor = 0x888888;
                else outlineColor = settings.Game.WALL_COLOR;
                blinkFrame = !blinkFrame;

                // recalculate the 
                sinX = 0;
                sinB = Math.floor(countdown/2);
                
                // update the graphics so we see the update / the change.
                updateGraphics();
            }
        }
    }
}