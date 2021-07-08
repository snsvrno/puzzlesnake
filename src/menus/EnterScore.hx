package menus;

function enterScore(width : Int, height : Int) : menu.Menu {

    var menu = new menu.Menu(width, height, "High Score!!");

    var name = new menu.components.LetterEntry("Name",3);
    name.disableSelectEffects = true;
    name.onActivateCallback = function(_) {
        game.Game.addHighScore(name.getText(), game.Game.instance.stats.score, game.Game.instance.options.colors);
        game.Game.replaceMenu(menus.HighScores.highScores(width, height));
    };
    menu.addItem(name);

    menu.selectItem(0);
    menu.verticalScroll = false;

    return menu;
}
