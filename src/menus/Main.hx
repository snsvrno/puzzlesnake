package menus;

function main(width : Int, height : Int) : menu.Menu {
    // testing for the menu
    var menu = new menu.Menu(width, height);

    // START GAME
    // initalizes a new game erasing all progress
    var play = new menu.components.Choice("Start Game!");
    play.onPress = function() {
        game.Game.newGame();
    }
    menu.addItem(play);

    // CONTINUE GAME
    // will only show if the player is currently in a game, will
    // continue the existing game.
    
    var gameOptions = new menu.components.Choice("Game Options");
    gameOptions.onPress = function() {
        // adds the menu to the stack.
        game.Game.setMenu(menus.GameOptions.gameOptions(width, height));
    }
    menu.addItem(gameOptions);
    
    var visualOptions = new menu.components.Choice("Visual Options");
    visualOptions.onPress = function() {
        // adds the menu to the stack.
        game.Game.setMenu(menus.VisualOptions.visualOptions(width, height));
    }
    menu.addItem(visualOptions);

    
    var highScores = new menu.components.Choice("High Scores");
    highScores.onPress = function() {
        // adds the menu to the stack.
        game.Game.setMenu(menus.HighScores.highScores(width, height));
    }
    menu.addItem(highScores);

    

    var exit = new menu.components.Choice("Quit");
    exit.onPress = () -> game.Game.instance.quit();
    menu.addItem(exit);

    // selects the first item.
    menu.selectItem();
    return menu;
}