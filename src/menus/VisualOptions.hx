package menus;

import game.Game;

function visualOptions(width : Int, height : Int) : menu.Menu {
    // testing for the menu
    var menu = new menu.Menu(width, height, "Visual Options");
    menu.setDescription("options to adjust the gameplay and difficulty (changes aren't made until a new game is started)");

    var paletteChoice = new menu.components.MultiItem("Palette");
    var currentPalette = 0;
    for (p in palettes.Palettes.all) {
        // we load each palette.
        var i = paletteChoice.addChoice(p.name);
        if (p.name == Settings.currentPalette) currentPalette = i;
    }
    paletteChoice.onSelect = (position : Int) -> Settings.setPalette(palettes.Palettes.all[position]);
    paletteChoice.setOriginalSelectedPosition(currentPalette);
    menu.addItem(paletteChoice);

    var bubbleShader = new menu.components.Toggle("Bubble Effect");
    bubbleShader.originalState = Game.instance.bubbleShaderEnabled();
    bubbleShader.onToggle = (state : Bool) -> game.Game.instance.toggleBubbleShader(state);
    menu.addItem(bubbleShader);

    var crtShader = new menu.components.Toggle("CRT Effect");
    crtShader.originalState = Game.instance.crtShaderEnabled();
    crtShader.onToggle = (state : Bool) -> game.Game.instance.toggleCrtShader(state);
    menu.addItem(crtShader);

    var bloomShader = new menu.components.Toggle("Bloom Effect");
    bloomShader.originalState = Game.instance.bloomShaderEnabled();
    bloomShader.onToggle = (state : Bool) -> game.Game.instance.toggleBloomShader(state);
    menu.addItem(bloomShader);

    #if !js
    // the javascript release will not have a fullscreen option.
    var fullScreen = {
        var window = hxd.Window.getInstance();
        new menu.components.Toggle("Fullscreen", window.displayMode == Borderless);
    }

    fullScreen.onToggle = function(state : Bool){ 
        var window = hxd.Window.getInstance();
        
        if (window.displayMode == Borderless) window.displayMode = Windowed;
        else window.displayMode = Borderless;
    };
    menu.addItem(fullScreen);

    #end

    ////////////////////////////////
    // the 'ok' or 'cancel' selection 
    var confirmation = new menu.components.ChoiceItem();
    confirmation.addChoice("Ok", function() {
        // everything is good, we keep all the setings that have been changed.
        game.Game.save();
        game.Game.shiftMenu();
    });
    confirmation.addChoice("Cancel", function() {
        // we should revert everything back to the original options
        bubbleShader.reset();
        crtShader.reset();
        #if !js
        fullScreen.reset();
        #end
        paletteChoice.reset();
        // go back
        game.Game.shiftMenu();
    });
    menu.addItem(confirmation);

    ////////////////////////////////
    // selects the first item.
    menu.selectItem();
    return menu;
}