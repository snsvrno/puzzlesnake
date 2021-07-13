package menu.components;

class LetterEntry extends Item {

    private var flex : h2d.Flow;
    private var letterFlex : h2d.Flow;
    private var textObject : h2d.Text;
    private var outline : h2d.filter.Outline;

    private var letters : Array<LetterEntryLetter>;

    private var selectedCharacter : Int = 0;

    public var disableSelectEffects : Bool = false;

    public function new(title : String, letters : Int, ?parent : h2d.Object) {
        super(parent);

        // creates a stack for all the items.
        flex = new h2d.Flow(this);
        flex.layout = h2d.Flow.FlowLayout.Horizontal;
        flex.horizontalSpacing = 50;

        textObject = new h2d.Text(hxd.res.DefaultFont.get(), flex);
        textObject.color = h3d.Vector.fromColor(Settings.ui1Color);
        textObject.text = title;

        letterFlex = new h2d.Flow(flex);
        letterFlex.layout = h2d.Flow.FlowLayout.Horizontal;
        letterFlex.horizontalSpacing = 6;
        flex.horizontalSpacing = 12;

        this.letters = [];

        for (_ in 0 ... letters) {
            var letter = new LetterEntryLetter(letterFlex);
            letter.color = Settings.ui1Color;

            this.letters.push(letter);
        }

        // creates the outline filter.
        outline = new h2d.filter.Outline(settings.MenuItem.OUTLINE_SIZE, Settings.ui2Color, 1);
        textObject.filter = outline;
    }

    public function getText() : String {
        var text : String = "";
        for (letter in letters) text += letter.text;
        return text;
    }

    /**
     * sets the text of the letter entry
     * 
     * if the supplied text is larger than the letterEntry object then it will be 
     * cut off, if the supplied text is smaller then it will be padded with spaces.
     * @param text 
     * @return String
     */
    public function setText(text : String) : String {
        for (i in 0 ... letters.length) {
            if (i < text.length) letters[i].text = text.charAt(i);
            else letters[i].text = "";
        }
        return text;
    }

    override function verticalScroll(direction:Int) {
        if (direction < 0) letters[selectedCharacter].scrollUp();
        else if (direction > 0) letters[selectedCharacter].scrollDown();
    }

    override function moveChoice(direction:Int) {
        if (direction > 0) selectedCharacter += 1;
        else if (direction < 0) selectedCharacter -=1;

        if (selectedCharacter < 0) selectedCharacter = letters.length-1;
        else if (selectedCharacter >= letters.length) selectedCharacter = 0;

        setSelected();
    }

    override public function setSelected() : Bool { 
        super.setSelected();

        if (disableSelectEffects == false) {
            outline.color = Settings.uiSelectedColor;
            textObject.color = h3d.Vector.fromColor(Settings.ui2Color);
        }

        for (i in 0 ... letters.length) {
            if (i == selectedCharacter) letters[i].setSelected();
            else letters[i].setUnselected();
        }

        return true;
    }

    override public function setUnSelected() { 
        super.setUnSelected();

        if (disableSelectEffects == false) {
            outline.color = Settings.ui2Color;
            textObject.color = h3d.Vector.fromColor(Settings.ui1Color);
        }

        for (letter in letters) letter.setUnselected();
    }
}