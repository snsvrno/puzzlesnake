package menus;

function gameOptions(width : Int, height : Int) : menu.Menu {
    
    var menu = new menu.Menu(width, height, "Game Options");
    menu.setDescription("options to adjust the gameplay and difficulty (changes aren't made until a new game is started)");

    // the available colors from the settings.
    var colors = new menu.components.ColorItem("Colors");

    ////////////////////////////////
    // the OK & cancel functions that we have so we can call them in multiple places.

    var okFunction = function() {
        // need to add 1 because we are going from `index` to `count`
        game.Game.instance.options.colors = colors.selected + 1;

        // checks if we should update the game, only does this
        // right now if the game hasn't started yet and is in the
        // "demo" mode.
        if (game.Game.instance.pause == false) game.Game.hotReload();
        // we were already playing then it will have to start a new game
        // because you edited game options.
        else game.Game.hotReload();

        game.Game.shiftMenu();
    };

    var cancelFunction = function() {
        // don't save anything that we chanced, just go back.
        game.Game.shiftMenu();
    };
    
    ////////////////////////////////
    // number of food colors 
    colors.setColors(Settings.getFoodColors());
    colors.setSelectedPosition(game.Game.instance.options.colors-1);
    colors.onPress = okFunction;
    menu.addItem(colors);

    ////////////////////////////////
    // the 'ok' or 'cancel' selection 
    var confirmation = new menu.components.ChoiceItem();
    confirmation.addChoice("Ok", okFunction);
    confirmation.addChoice("Cancel", cancelFunction);
    menu.addItem(confirmation);

    ////////////////////////////////
    // selects the first item.
    menu.selectItem();
    return menu;
}