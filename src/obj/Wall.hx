package obj;

class Wall extends GridObject {

	public final variant : Int;
    public final value : Int = 1;
    public var eatable(default, null) : Bool = false;
    
    // for the blinking when its eatable
    private var countdown : Int = 0;
    private var sinB : Int;
    private var sinX : Int = 0;
    private var blinkFrame : Bool = false;

	public function new(variant : Int, ?parent : h2d.Object) {
		super(parent);

        this.variant = variant;
        outlineColor = Settings.getFoodColor(variant);

        fillColor = Settings.wallColor;
        outlineSize = 4;

		updateGraphics();
	}

    public function setEatable() {
        eatable = true;
        countdown = settings.Game.STEROID_LASTING_TIME;
        outlineColor = Settings.wallColor;
        fillColor = Settings.getFoodColor(variant);
        sinB = Math.floor(settings.Game.STEROID_LASTING_TIME / 2);

		updateGraphics();
    }

    override function forceRedraw() {
        // updates the colors
        if (eatable) {
            // we are going to reuse setEatable to set the colors, but
            // we're going to save the countdown and the sinB
            var oldSinB = sinB;
            var oldCountdown = countdown;

            setEatable();

            sinB = oldSinB;
            countdown = oldCountdown;
        } else {
            // if we aren't eatable at this point then we do a simpler
            // coloring
            outlineColor = Settings.getFoodColor(variant);
            fillColor = Settings.wallColor;
        }
        
        // draws it again.
        super.forceRedraw();
    }

    override function turnTick() {
        if (eatable) {

            countdown -= 1;
            
            if (countdown <= 0) {
                eatable = false;
                outlineColor = Settings.getFoodColor(variant);
                fillColor = Settings.wallColor;
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
                else outlineColor = Settings.wallColor;
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