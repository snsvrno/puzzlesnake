package menu.components;

private enum ColorTileState {
    Selected;
    Highlighted;
    Unselected;
}

/**
 * a square tile that displays a single color.
 */
class ColorTile extends h2d.Graphics {
    
    private final colorValue : Int;
    private var state : ColorTileState = Unselected;
    private var size : Int = 0;


    public function new(color : Int, ?parent : h2d.Object) {
        super(parent);

        colorValue = color;
    }

    public function setHighlighted() {
        state = Highlighted;
        drawColor();
    }

    public function setSelected() {
        state = Selected;
        drawColor();
    }

    public function setUnselected() {
        state = Unselected;
        drawColor();
    }

    public function drawColor(?size : Int) {
        if (size != null) this.size = size;

        clear();

        beginFill(colorValue);
        drawRect(0, 0, this.size, this.size);

        switch(state) {

            // if the state is unselected then we need to darken the tile
            case Unselected:
                beginFill(0x000000, 0.65);
                drawRect(0, 0, this.size, this.size);

            // we do nothing if it is selected
            case Selected:

            // highlighted means that this is the currently "over" item.
            case Highlighted:
                endFill();
                lineStyle(1, 0xFFFFFF);
                drawRect(0, 0, this.size, this.size);
        }

        endFill();
    }
}