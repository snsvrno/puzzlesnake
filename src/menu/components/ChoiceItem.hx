package menu.components;

/**
 * A menu item that doesn't have a 'title' but rather shows
 * a number of options that can be used. example of this would be
 * the 'ok' 'cancel' item
 */
class ChoiceItem extends Item {
    
    private var selected : Int = 0;
    private var choices : Array<Choice> = [];
    private var flex : h2d.Flow;

    public function new (?parent : h2d.Object) {
        super(parent);

        flex = new h2d.Flow(this);
        flex.horizontalSpacing = settings.Menu.PADDING;
    }

    public function addChoice(title : String, action : () -> Void) {
        var newChoice = new Choice(title);
        newChoice.onPress = action;

        flex.addChild(newChoice);
        choices.push(newChoice);
    }

    override function setSelected() {
        for (i in 0 ... choices.length) {
            if (i == selected) choices[i].setSelected();
            else choices[i].setUnSelected();
        }
    }

    override function setUnSelected() {
        for (i in 0 ... choices.length) choices[i].setUnSelected();
    }

    override function moveChoice(direction:Int) {
        if (direction < 0) selected -= 1;
        else if (direction > 0) selected += 1;

        if (selected > choices.length-1) selected = 0;
        else if (selected < 0) selected = choices.length - 1;

        setSelected();
    }

    override function activate() {
        choices[selected].activate();
    }
}