package menu;

class Item extends h2d.Object {

    #if debug
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    private var debug_graphics : debug.Bounds;
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #end
    
    ///////////////////////////////////////////////////////////////////////////
    // PRIVATE MEMBERS
    private var textObject : h2d.Text;
    private var outline : h2d.filter.Outline;

    /*** the values of the various choices */
    private var choices : Array<String> = [];
    // the three choice text objects when using choices.
    private var choiceLeft : Null<h2d.Text>;
    private var choiceMiddle : Null<h2d.Text>;
    private var choiceRight : Null<h2d.Text>;
    /*** the selected choice */
    private var selectedChoice : Int = 0;

    ///////////////////////////////////////////////////////////////////////////
    // PUBLIC MEMBERS
    public var height : Int;
    public var width : Int;

    public var onPress : Null<() -> Void>;

    public function new(?text : String, ?parent : h2d.Object) {
        super(parent);

        // creates the text object.
        textObject = new h2d.Text(hxd.res.DefaultFont.get(), this);
        textObject.setScale(2);

        // creates the outline filter.
        outline = new h2d.filter.Outline(settings.MenuItem.OUTLINE_SIZE, settings.MenuItem.OUTLINE_OVER_COLOR, 1);
        textObject.filter = outline;

        #if debug
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // creates a bounding box around the item
        debug_graphics = new debug.Bounds();
        debug_graphics.lineColor = settings.MenuItem.DEBUG_BOUNDS_COLOR;
        game.Game.debug_graphics.add(debug_graphics, this);
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        #end

        if (text != null) setText(text);
        else setText("<item>");
    }

    /**
     * sets the display text for the item. as well
     * as positions everything.
     * @param text 
     */
    public function setText(?text : String) {

        // changes the text.
        if (text != null) {
            textObject.text = text;

            textObject.x = -textObject.textWidth / 2 * textObject.scaleX;
            textObject.y = -textObject.textHeight / 2 * textObject.scaleY;

            height = Math.ceil(textObject.textHeight * textObject.scaleY);
            width = Math.ceil(textObject.textWidth * textObject.scaleX);
        }

        // positions the text and choices if exist.
        if (choices.length > 0) {

            // checks all the choices and gets the largest width
            // so we know the spacing.
            var largestWidth = { 
                var workingWidth = 0.0;
                var workingFont = new h2d.Text(hxd.res.DefaultFont.get());
                for (c in choices) {
                    workingFont.text = c;
                    if (workingFont.textWidth > workingWidth) workingWidth = workingFont.textWidth;
                }
                workingWidth;
            }
            // fixes the overall width of the object.
            width += Math.ceil(largestWidth * (choices.length - 1)
                + largestWidth * settings.MenuItem.SELECTED_CHOICE_SIZE
                + settings.MenuItem.CHOICE_PADDING * (choices.length - 1) 
                + settings.MenuItem.ITEM_CHOICE_PADDING);
            // adjusts the main text horizontally to give space for the choices.
            textObject.x = - textObject.textWidth / 2 * textObject.scaleX
                - largestWidth * (choices.length - 1) / 2
                - largestWidth * settings.MenuItem.SELECTED_CHOICE_SIZE / 2
                - settings.MenuItem.CHOICE_PADDING * (choices.length - 1) / 2
                - settings.MenuItem.ITEM_CHOICE_PADDING / 2;
            // sets the choice positions
            choiceLeft.y = -choiceLeft.textHeight / 2 * choiceLeft.scaleY;
            choiceLeft.x = textObject.x + textObject.textWidth * textObject.scaleX + settings.MenuItem.ITEM_CHOICE_PADDING + largestWidth/2;

            choiceMiddle.y = -choiceMiddle.textHeight / 2 * choiceMiddle.scaleY;
            choiceMiddle.x = choiceLeft.x + largestWidth + settings.MenuItem.CHOICE_PADDING + largestWidth/2 * settings.MenuItem.SELECTED_CHOICE_SIZE ;

            choiceRight.y = -choiceRight.textHeight / 2 * choiceRight.scaleY;
            choiceRight.x = choiceMiddle.x + largestWidth * settings.MenuItem.SELECTED_CHOICE_SIZE  + settings.MenuItem.CHOICE_PADDING + largestWidth/2;
        }

        

        #if debug
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        debug_graphics.x = -width/2;
        debug_graphics.y = -height/2;
        debug_graphics.width = width;
        debug_graphics.height = height;
        debug_graphics.updateGraphics();
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        #end
    }

    /**
     * attempts to set the selected choice to match the
     * text. if it can't find a choice that is similar
     * then it will just selected the first choice.
     * @param text 
     */
    public function setChoice(text : String) {

        if (choices.length == 0) return;

        for (i in 0 ... choices.length) {
            if (choices[i] == text) {
                selectedChoice = i;
                updateChoices();
                return;
            }
        }

    }

    public function getChoice() : Null<String> {
        if (choices.length == 0) return null;
        else return choices[selectedChoice];
    }

    public function setChoices(... newChoices : String) {

        // removes the old choices if any.
        while(choices.length > 0) choices.pop();
        
        // sets the new choices.
        for (c in newChoices) choices.push(c);
 
        // creates the choice text if not initalized. we are only
        // going to check the first one because they should all be
        // made at the same time.
        if (choiceLeft == null) {
            choiceLeft = new h2d.Text(hxd.res.DefaultFont.get(), this);
            choiceLeft.textAlign = Center;

            choiceMiddle = new h2d.Text(hxd.res.DefaultFont.get(), this);
            choiceMiddle.filter = outline;
            choiceMiddle.setScale(settings.MenuItem.SELECTED_CHOICE_SIZE);
            choiceMiddle.textAlign = Center;

            choiceRight = new h2d.Text(hxd.res.DefaultFont.get(), this);
            choiceRight.textAlign = Center;
        }

        setText();

        // sets the choices
        updateChoices();

    }

    public function moveChoice(direction : Int) {
        
        // if we don't have any choices we don't do anything.
        if (choices.length == 0) return;

        selectedChoice = getChoiceIndex(direction);

        updateChoices();
    }

    /**
     * gets the index of the choice a direction
     * away from the current index. `getChoiceIndex(0)`
     * would return the current index.
     * 
     * @param direction integer representation of direction, only uses sign.
     */
    private function getChoiceIndex(direction : Int) : Int {

        var newPos = selectedChoice;

        // a check to make sure we get the direction of the 
        // int and not the actual value of the int.
        if (direction > 0) newPos += 1;
        else newPos -= 1;

        // checkinf the choice (index) to make sure it
        // is valid
        if (newPos < 0) newPos = choices.length-1;
        else if (newPos > choices.length - 1) newPos = 0;

        return newPos;
    }

    public function activate() {
        if (onPress != null) onPress();
    }

    public function setSelected() outline.color = settings.MenuItem.OUTLINE_OVER_COLOR;
    public function setUnSelected() outline.color = settings.MenuItem.OUTLINE_COLOR;

    /**
     * updates the text objects with the correct text.
     */
    private function updateChoices() {

        // just a check to make sure we don't do anything weird if there
        // are no choices.
        if (choices.length == 0) return;

        choiceLeft.text = choices[getChoiceIndex(-1)];
        choiceMiddle.text = choices[selectedChoice];
        choiceRight.text = choices[getChoiceIndex(1)];

    }

}