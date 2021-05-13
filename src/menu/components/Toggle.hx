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
        textObject.text = text;

        stateText = new h2d.Text(hxd.res.DefaultFont.get(), flex);
        setStateText();

        outline = new h2d.filter.Outline(settings.MenuItem.OUTLINE_SIZE, settings.MenuItem.OUTLINE_OVER_COLOR, 1);
        textObject.filter = outline;
    }

    override function activate() {
        state = !state;

        super.activate();
        if (onToggle != null) onToggle(state);

        setStateText();
    }

    override public function setSelected() outline.color = settings.MenuItem.OUTLINE_OVER_COLOR;
    override public function setUnSelected() outline.color = settings.MenuItem.OUTLINE_COLOR;

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