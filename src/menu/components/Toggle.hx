package menu.components;

class Toggle extends Item {

    /**
     * the state that this object original was when created, that way
     * we can reset back to it if we decide to cancel it.
     */
    public var originalState(default, set) : Bool;
    private function set_originalState(state : Bool) : Bool {
        originalState = state;
        this.state = state;
        // to catch the circular reference where we can't set
        // the text unless this state exists, and we can set
        // the state unless the text exists.
        if (stateText != null) setStateText();
        return originalState;
    }

    public var state : Bool;

    private var flex : h2d.Flow;
            
    private var outline : h2d.filter.Outline;
    private var textObject : h2d.Text;
    private var stateText : h2d.Text;

    public var onToggle : Null<(state : Bool) -> Void>;

    public function new(text : String, ?startingState : Bool = false, ?parent : h2d.Object) {
        super(parent);

        originalState = startingState;
        state = originalState;

        flex = new h2d.Flow(this);
        flex.horizontalSpacing = settings.Menu.PADDING;

        textObject = new h2d.Text(hxd.res.DefaultFont.get(), flex);
        textObject.color = h3d.Vector.fromColor(Settings.ui1Color);
        textObject.text = text;

        stateText = new h2d.Text(hxd.res.DefaultFont.get(), flex);
        stateText.color = h3d.Vector.fromColor(Settings.ui1Color);
        setStateText();

        outline = new h2d.filter.Outline(settings.MenuItem.OUTLINE_SIZE, Settings.ui2Color, 1);
        textObject.filter = outline;
    }

    override function activate() {
        state = !state;

        super.activate();
        if (onToggle != null) onToggle(state);

        setStateText();
    }

    override public function setSelected() {
        super.setSelected();
        outline.color = Settings.uiSelectedColor;
        textObject.color = h3d.Vector.fromColor(Settings.ui2Color);
        stateText.color = h3d.Vector.fromColor(Settings.uiSelectedColor);
    }

    override public function setUnSelected() { 
        super.setUnSelected();
        isSelected = false;
        outline.color = Settings.ui2Color;
        textObject.color = h3d.Vector.fromColor(Settings.ui1Color);
        stateText.color = h3d.Vector.fromColor(Settings.ui1Color);
    }

    override public function moveChoice(_ : Int) activate();

    private function setStateText() {
        if (state) stateText.text = "Enabled";
        else stateText.text = "Disabled";
    }

    /**
     * return this toggle to its original state, and 
     * trigger any callbacks.
     */
    public function reset() {

        // so we do the opposite here because we are going to toggle it
        // when we activate it ... probably not the best way to do this.
        state = !originalState;
        activate();
    }
}