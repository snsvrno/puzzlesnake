package menus;

function gameOptions(width : Int, height : Int) : menu.Menu {
    // testing for the menu
    var menu = new menu.Menu(width, height, "Game Options");
    menu.setDescription("options to adjust the gameplay and difficulty (changes aren't made until a new game is started)");

    // COLORS
    // adjusts how many colors to play with
    var colors = new menu.Item("Colors");
    colors.setChoices("2","3","4","5");
    colors.setChoice('${game.Game.instance.options.colors}');
    menu.addItem(colors);

    // SAVE (ok)
    // saves the game options.
    var save = new menu.Item("Save");
    save.onPress = function() {


        var color = Std.parseInt(colors.getChoice());
        if (color != null) game.Game.instance.options.colors = color;


        // checks if we should update the game, only does this
        // right now if the game hasn't started yet and is in the
        // "demo" mode.
        if (game.Game.instance.pause == false) game.Game.hotReload();
        game.Game.shiftMenu();
    }
    menu.addItem(save);

    var back = new menu.Item("Cancel");
    back.onPress = function() {
        game.Game.shiftMenu();
    }
    menu.addItem(back);

    // selects the first item.
    menu.selectItem();
    return menu;
}