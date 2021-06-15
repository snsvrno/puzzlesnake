package structures;

typedef ColorPalette = {
    
    var name : String;

    /*** should be 6 colors for the 6 foods. */
    var foods : Array<Int>;
    
    /***  the background color*/
    var background : Int;
    
    /*** the wall outline / center color */
    var wall : Int;

    var ui1 : Int;
    var ui2 : Int;
    var uiSelected : Int;
};