package menus;

import game.Game;

function gameOptions(width : Int, height : Int) : menu.Menu {
    // testing for the menu
    var menu = new menu.Menu(width, height, "Game Options");
    menu.setDescription("options to adjust the gameplay and difficulty (changes aren't made until a new game is started)");
    
    ////////////////////////////////
    // number of food colors 
    var colors = new menu.components.ColorItem("Colors");
    colors.setColors(Settings.getFoodColors());
    colors.setSelectedPosition(game.Game.instance.options.colors-1);
    menu.addItem(colors);

    ////////////////////////////////
    // the 'ok' or 'cancel' selection 
    var confirmation = new menu.components.ChoiceItem();
    confirmation.addChoice("Ok", function() {
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
    });
    confirmation.addChoice("Cancel", function() {
        // don't save anything that we chanced, just go back.
        game.Game.shiftMenu();
    });
    menu.addItem(confirmation);

    ////////////////////////////////
    // selects the first item.
    menu.selectItem();
    return menu;
}