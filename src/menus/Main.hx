package menus;

import menu.Item;

function main(width : Int, height : Int) : menu.Menu {
    // testing for the menu
    var menu = new menu.Menu(width, height);

    var play = new menu.Item("Play!");
    play.onPress = function() {
        game.Game.newGame();
    }
    menu.addItem(play);


    menu.addItem(new menu.Item());
    menu.selectItem();
    return menu;
}