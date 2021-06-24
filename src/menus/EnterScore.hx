package menus;

import menu.components.LetterEntry;

function enterScore(width : Int, height : Int) : menu.Menu {

    var menu = new menu.Menu(width, height, "High Score!!");

    var name = new menu.components.LetterEntry("Name",3);
    menu.addItem(name);

    var okButton = new menu.components.Choice("Ok");
    okButton.onPress = function() {

        game.Game.addHighScore(name.getText(), game.Game.instance.stats.score, game.Game.instance.options.colors);

        game.Game.replaceMenu(menus.HighScores.highScores(width, height));
    };
    menu.addItem(okButton);

    return menu;
}
