package menu.components;

import h2d.Interactive;

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

    private var interactive : h2d.Interactive;
    public var onOverCallback : Null<(item : ColorTile) -> Void>;
    public var onActivateCallback : Null<(item : ColorTile) -> Void>;


    public function new(color : Int, ?parent : h2d.Object) {
        super(parent);

        colorValue = color;
        interactive = new h2d.Interactive(0, 0, this);
        interactive.onOver = (_) -> if (onOverCallback != null) onOverCallback(this);
        interactive.onClick = (_) -> if (onActivateCallback != null) onActivateCallback(this);
        interactive.propagateEvents = true;
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
        if (size != null) { 
            this.size = size;
            interactive.height = interactive.width = size;
        }

        clear();

        beginFill(colorValue);
        drawRect(0, 0, this.size, this.size);

        switch(state) {

            // if the state is unselected then we need to darken the tile
            case Unselected:
                clear();
                beginFill(tools.Colors.grayScale(colorValue));
                drawRect(0, 0, this.size, this.size);

            // we do nothing if it is selected
            case Selected:

            // highlighted means that this is the currently "over" item.
            case Highlighted:
                endFill();
                lineStyle(1, Settings.uiSelectedColor);
                drawRect(0, 0, this.size, this.size);
        }

        endFill();
    }
}