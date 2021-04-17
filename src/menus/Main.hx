package menus;

function main(width : Int, height : Int) : menu.Menu {
    // testing for the menu
    var menu = new menu.Menu(width, height);

    // START GAME
    // initalizes a new game erasing all progress
    var play = new menu.Item("Start Game!");
    play.onPress = function() {
        game.Game.newGame();
    }
    menu.addItem(play);

    // CONTINUE GAME
    // will only show if the player is currently in a game, will
    // continue the existing game.

    // GAME OPTIONS
    // where the player can change difficulty settings
    var gameOptions = new menu.Item("Game Options");
    gameOptions.onPress = function() {
        // adds the menu to the stack.
        game.Game.setMenu(menus.GameOptions.gameOptions(width, height));
    }
    menu.addItem(gameOptions);

    // selects the first item.
    menu.selectItem();
    return menu;
}