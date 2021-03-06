package ui;

class Manager extends h2d.Object {

    private var background : h2d.Graphics;

    private var foods : Array<ui.Food> = [];
    private var score : Null<ui.Score>;

    public final height : Int;
    public final width : Int;

    public function new(width : Int, height : Int, parent : h2d.Object) {
        super(parent);

        this.height = height;
        this.width = width;

        background = new h2d.Graphics(this);
        drawBackground();
    }

    private function drawBackground() {
        background.clear();
        
        background.lineStyle(settings.Ui.BORDER_SIZE, Settings.ui2Color);
        background.beginFill(Settings.ui2Color);
        background.drawRect(0,0,this.width,this.height);
        background.endFill();
    }

    public function createFoodIndicators(count : Int) {
        cleanFoodIndicators();

        var padding = height/2;
        var xpos = padding;
        for (i in 0 ... count) {
            var color = new ui.Food(i, this);
            color.y = height/2;
            color.x = xpos;
            xpos += color.width + padding;
            foods.push(color);
        }
    }

    public function createScore() {
        if (score == null) { 
            score = new ui.Score(this);
            score.x = width - height/2;
            score.y = height/2;
        } else {
            score.value = 0;
            score.visible = true;
        }
    }

    /**
     * Removes all the existing food indicator items.
     */
    public function cleanFoodIndicators() {
        while (foods.length > 0) removeChild(foods.pop());
    }

    public function getFood(variant : Int) : Null<ui.Food> {
        for (f in foods) {
            if (f.variant == variant) { 
                return f;
            }
        }
        return null;
    }   

    public function addToScore(adder : Int) {
        if (score != null) {
            score.value += adder;
            score.visible = true;
        }
    }

    public function setScore(newValue : Int) {
        if (score != null) { 
            score.value = newValue;
            score.visible = true;
        }
    }

    public function hideScore() {
        score.visible = false;
    }

    public function forceRedraw() {
        drawBackground();

        for (f in foods) f.forceRedraw();
        score.forceRedraw();
    }

}