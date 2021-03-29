package ui;

class MenuItem extends h2d.Object {

	inline static private var CHOICESSPACE = 10;
	inline static private var CHOICESTEXTSPACE = 40;
	inline static private var CHOICESNOTSELECTED = 0.75;
	inline static private var CHOICESNOTSELECTEDCOLOR = 0xFF444444;
	inline static private var SCALE = 2;

	private var textObject : h2d.Text;
	private var overFilter : h2d.filter.Filter = new h2d.filter.Outline(1,Settings.MENUITEMOVERCOLOR, 1);

	public var onPressed : Null<() -> Void>;
	private var choices : Array<String>;
	private var selectedChoice : Int;
	private var textChoices : Array<h2d.Text>;

	public var choice(get, null) : Null<String>;
	private function get_choice() : Null<String> {
		if (choices == null) return null;
		else return choices[selectedChoice];
	}
	
	public var over(default, set) : Bool = false;
	private function set_over(state : Bool) : Bool {
		if (state) textObject.filter = overFilter;
		else textObject.filter = null;

		if (textChoices != null) {
			if (state) textChoices[1].filter = overFilter;
			else textChoices[1].filter = null;
		}

		return !(textObject.filter == null);
	}

	public function new(text : String, ?parent : h2d.Object) {
		super(parent);

		textObject = new h2d.Text(hxd.res.DefaultFont.get(), this);
		textObject.text = text;
		name = text;
		textObject.setScale(SCALE);

		setPlacement();
	}

	private function setPlacement() {
		textObject.x = -1 * textObject.textWidth / 2 * textObject.scaleX;
		textObject.y = -1 * textObject.textHeight / 2 * textObject.scaleY;
	}

	public function pressed() {
		if (onPressed != null) onPressed();
	}

	public function setChoices(choices : Array<String>) {
		this.choices = choices;

		textChoices = [];
		textChoices.push(new h2d.Text(hxd.res.DefaultFont.get(), this));
		textChoices.push(new h2d.Text(hxd.res.DefaultFont.get(), this));
		textChoices.push(new h2d.Text(hxd.res.DefaultFont.get(), this));

		textChoices[0].setScale(SCALE * CHOICESNOTSELECTED);
		textChoices[0].color.setColor(CHOICESNOTSELECTEDCOLOR);

		textChoices[1].setScale(SCALE);

		textChoices[2].setScale(SCALE * CHOICESNOTSELECTED);
		textChoices[2].color.setColor(CHOICESNOTSELECTEDCOLOR);

		var maxwidth = 0.0;
		for (s in choices) {
			textChoices[1].text = s;
			if (textChoices[1].textWidth > maxwidth) maxwidth = textChoices[1].textWidth;
		}

		// sets the position of everything.
		var totalwidth = textObject.textWidth * textObject.scaleX + CHOICESSPACE * 2 + CHOICESTEXTSPACE + 2 * maxwidth * textChoices[0].scaleX + 1 * maxwidth * textChoices[1].scaleX;
		var xspace = -totalwidth/2;

		textObject.x = xspace;
		xspace += textObject.textWidth * textObject.scaleX + CHOICESTEXTSPACE;

		textChoices[0].x = xspace;
		textChoices[0].y = -1 * textChoices[0].textHeight/2* textChoices[0].scaleY;
		xspace += maxwidth * textChoices[0].scaleX + CHOICESSPACE;

		textChoices[1].x = xspace;
		textChoices[1].y = -1 * textChoices[1].textHeight/2* textChoices[1].scaleY;
		xspace += maxwidth * textChoices[1].scaleX + CHOICESSPACE;

		textChoices[2].x = xspace;
		textChoices[2].y = -1 * textChoices[2].textHeight/2* textChoices[2].scaleY;
		xspace += maxwidth * textChoices[2].scaleX + CHOICESSPACE;

		setChoiceDisplay();
	}

	public function setChoice(choice : String) {
		var index = choices.indexOf(choice);
		if (index > 0) { 
			selectedChoice = index;
			setChoiceDisplay();
		}
	}

	public function moveChoice(direction : Int) {
		if (direction > 0) {
			selectedChoice += 1;
			if (selectedChoice >= choices.length) selectedChoice = 0;
		} else {
			selectedChoice -= 1;
			if (selectedChoice < 0) selectedChoice = choices.length-1;
		}

		setChoiceDisplay();
		
	}

	private function setChoiceDisplay() {

		// sets the choices
		textChoices[1].text = choices[selectedChoice];
		
		if (selectedChoice == 0) textChoices[0].text = choices[choices.length-1];
		else textChoices[0].text = choices[selectedChoice-1];
		
		if (selectedChoice == choices.length - 1) textChoices[2].text = choices[0];
		else textChoices[2].text = choices[selectedChoice+1];
	}
}