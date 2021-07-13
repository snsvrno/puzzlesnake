package menus;

function highScores(width : Int, height : Int) : menu.Menu {
    // testing for the menu
    var menu = new menu.Menu(width, height, "High Scores");

    var colors = new menu.components.ColorItem("");
    menu.addItem(colors);

    var scores = [ ];
    for (i in 0 ... 5) {
        var line = new menu.components.Text("");
        scores.push(line);
        menu.addItem(line);
    }

    colors.setColors(Settings.getFoodColors());
    colors.onChoice = function(choice : Int) {
        generateScores(choice, scores);
    }
    colors.setSelectedPosition(game.Game.instance.options.colors-1);

    var okButton = new menu.components.Choice("Ok");
    okButton.onPress = function() {
        game.Game.shiftMenuOrSet(menus.Main.main(width, height));
    };
    menu.addItem(okButton);

    menu.selectItem();
    return menu;
}

function generateScores(difficulty : Int, items : Array<menu.components.Text>) {

    for (i in 0 ... items.length) {
        var name : String = "___";
        var score : String = "0000";

        var cluster = game.Game.highScores[difficulty];
        if (cluster != null && cluster[i] != null) {
            name = cluster[i].name;
            score = '${cluster[i].score}';

            while(score.length < 4) score = "0" + score;
        }

        items[i].setText('$name .... $score');
    }
}