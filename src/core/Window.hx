package core;

/**
 * Contains all the higher level functions that aren't game specific
 * but should be handled by each game.
 */
class Window extends hxd.App {

	/////////////////////////////////////////////////
	// SCREEN EFFECTS
	// the container that contains all the filters / shaders that are 
	// applied to the entire world.
	private var filterEffects : h2d.filter.Group;
	// the distortion shader that makes it look like a CRT monitor
	private var bubble : shaders.Bubble; // the actual shader
	private var bubbleFilter : h2d.filter.Shader<shaders.Bubble>; // the screen filter object that contains the shader.
	// the color splitting shader that emulates LCD crystals
	private var crt : shaders.CRT; // the actual shader
	private var crtFilter : h2d.filter.Shader<shaders.CRT>;  // the screen filter object that contains the shader.
	// a bleed color intense shader
	private var bloomFilter : h2d.filter.Bloom;

	/*** the current window width */
	private var width : Int;
	/*** the current window height */
	private var height : Int;

	/*** the viewport size so we know how to resize the world to the window */
	private var viewportWidth : Int;
	/*** the viewport size so we know how to resize the world to the window */
	private var viewportHeight : Int;

	private var viewportPadding : structures.Padding = new structures.Padding();

	/**
	 * a fake scene layer where all the game stuff will be, so we 
	 * can better control the scale and positioning.
	 */
	private var world : h2d.Object;

	/**
	 * A background object that takes up the whole screen so we force the draw
	 * everywhere.
	 */
	private var backgroundFill : h2d.Graphics;

	//////////////////////////////////////////////////////////////////

	override function init() {		
		hxd.Window.getInstance().addEventTarget(onEvent);

		world = new h2d.Object(s2d);
		backgroundFill = new h2d.Graphics(world);

		initShaders();
	}

	private function initShaders() {
		// the container for all the effecs.
		filterEffects = new h2d.filter.Group();
		// applying it to the world
		s2d.filter = filterEffects;

		// setup the crt shader
		crt = new shaders.CRT();
		crtFilter = new h2d.filter.Shader(crt);
		filterEffects.add(crtFilter);

		// setting up the bubble shader.
		bubble = new shaders.Bubble();
		bubbleFilter = new h2d.filter.Shader(bubble);
		// set the background fill color so there isn't any 'black'
		bubble.backgroundColor.setColor(Settings.backgroundColor);
		filterEffects.add(bubbleFilter);

		// setting up the bloom shader.
		bloomFilter = new h2d.filter.Bloom(1,1,1,1.25,2);
		filterEffects.add(bloomFilter);

		bubbleFilter.enable = true;
		crtFilter.enable = true;
		bloomFilter.enable = true;
	}

	//////////////////////////////////////////////////////////////////
	// EVENT CALLBACKS

	/**
	 * called everytime there is an event.
	 * @param e 
	 */
	function onEvent(e : hxd.Event) { }

	override function onResize() {
		super.onResize();

		var window = hxd.Window.getInstance();

		// setting some variables so we have the information
		// always available.
		width = window.width;
		height = window.height;
		
		// adjust the scale of the game world object.
		// calculates the zoom for the x and y direction based on the zoom
		// settings
		var scalex = (window.width - viewportPadding.left - viewportPadding.right) / (viewportWidth);
		var scaley = (window.height - viewportPadding.top - viewportPadding.bottom) / (viewportHeight);

		// calculates the new scale
		// we are going to round it to a factor of 2 so that it comes out nice
		// when it is displayed on the screen.
		var chosenScale = {
			var perfectScale = Math.min(scalex, scaley); 
			
			// using 2 decimal places.
			var newScale = perfectScale * 100;
			newScale = Math.round(newScale);

			// if we are odd then we add 1.
			if (newScale % 2 == 1) newScale += 1;

			// returning it to the decimal places used above.
			newScale / 100;
		};
		// sets the min to the layer.
		world.setScale(chosenScale);
		// moves the position so that the world is centered.
		// this doesn't move to the center of the world (0,0 aligned to center) because i started it
		// with 0,0 being top left and then added ui in the negative relm ... not sure why that was a
		// good idea? but that happened.
		world.x = viewportPadding.left + (window.width - viewportWidth * world.scaleX - viewportPadding.left - viewportPadding.right)/2;
		world.y = viewportPadding.top + (window.height - viewportHeight * world.scaleY - viewportPadding.top - viewportPadding.bottom)/2;

		// update the background fill.
		redrawBackground();

		crt.screenWidth = width;
		crt.screenHeight = height;
	}

	public function redrawBackground() {
		var window = hxd.Window.getInstance();

		backgroundFill.clear();
		backgroundFill.beginFill(0x000000);
		backgroundFill.drawRect(-world.x / world.scaleX,-world.y / world.scaleY, window.width / world.scaleX, window.height / world.scaleY);
		backgroundFill.endFill();

		// updating the background we are sending the shader, but only if we don't have the crt effect enabled.
		// this is because the crt effect doesn't go to the edge of the screen and its visible when using 
		// lighter backgrounds. if we have it enabled then we just send black.
		bubble.backgroundColor.setColor(0x000000);
	}

	//////////////////////////////////////////////////////////////////

	public function bloomShaderEnabled() : Bool return bloomFilter.enable;
	public function toggleBloomShader(?state : Bool) : Bool {
		if (state != null) return bloomFilter.enable = state;
		else return bloomFilter.enable = !bloomFilter.enable;
	}

	public function bubbleShaderEnabled() : Bool return bubbleFilter.enable;
	public function toggleBubbleShader(?state : Bool) : Bool { 
		if (state != null) return bubbleFilter.enable = state;
		else return bubbleFilter.enable = !bubbleFilter.enable;
	}

	public function crtShaderEnabled() : Bool return crtFilter.enable;
	public function toggleCrtShader(?state : Bool) : Bool { 
		if (state != null) crtFilter.enable = state;
		else crtFilter.enable = !crtFilter.enable;
		redrawBackground();
		return crtFilter.enable;
	}
}