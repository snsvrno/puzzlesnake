package ui;

typedef ItemDef = {
	text : String,
	?onpressed : () -> Void,
	?choices : Array<String>,
	?startingChoice : () -> String,
};

typedef MenuSet = {
	items : Array<MenuItem>,
	selected : Int,
};

class Menu extends h2d.Object {

	static private var instance : Menu;

	static private var mainMenuItems : Array<ItemDef> = [
		{ text : "Play", onpressed : () -> Menu.instance.createStartOptions() },
		{ text : "Options", onpressed : () -> Menu.instance.createSettingsOptions() },
	];

	static private var startOptions : Array<ItemDef> = [
		{ text : "Start Game!", onpressed : () -> Menu.instance.startGame() },
		{ text : "Colors", choices : ["2","3","4","5"] },
		{ text : "Back", onpressed : () -> Menu.instance.backMenu() },
	];

	static private var settingsOptions : Array<ItemDef> = [
		{ text : "CRT Effect", choices : ["On", "Off"], startingChoice : () -> if(Game.instance.hasBubble() == true) return "On" else return "Off" },
		{ text : "Scanlines", choices : ["On", "Off"], startingChoice : () -> if(Game.instance.hasScanlines() == true) return "On" else return "Off" },
		{ text : "Ok", onpressed : () -> Menu.instance.applySettings() },
		{ text : "Cancel", onpressed : () -> Menu.instance.backMenu() },
	];

	private var menus : Array<MenuSet> = [];

	private var width : Int;
	private var height : Int;

	public function new(width : Int, height : Int, ?parent : h2d.Object) {
		super(parent);
		instance = this;

		this.width = width;
		this.height = height;

		createBaseMenu();
	}

	private function createMenu(itemDefs : Array<ItemDef>) : Array<MenuItem> {
		var items : Array<MenuItem> = [];

		// creates the menu
		var space = 40;
		var ystart = height/2 - space/2 * (itemDefs.length - 1);
		for (mi in itemDefs) {
			var item = new MenuItem(mi.text, this);

			if (mi.onpressed != null) item.onPressed = mi.onpressed;
			if (mi.choices != null) item.setChoices(mi.choices);

			item.x = width / 2;
			item.y = ystart;
			ystart += space;

			if (mi.startingChoice != null) {
				var choice = mi.startingChoice();
				item.setChoice(choice);
			}

			items.push(item);
		}

		items[0].over = true;

		return items;
	}

	private function createBaseMenu() {
		menus.unshift({
			items: createMenu(mainMenuItems), selected:  0
		});

		for (i in 1 ... menus.length) {
			for (mi in menus[i].items) {
				removeChild(mi);
			}
		}
	}

	private function createStartOptions() {
		menus.unshift({
			items: createMenu(startOptions), selected:  0
		});

		for (i in 1 ... menus.length) {
			for (mi in menus[i].items) {
				removeChild(mi);
			}
		}
	}

	private function createSettingsOptions() {
		menus.unshift({
			items: createMenu(settingsOptions), selected:  0
		});

		for (i in 1 ... menus.length) {
			for (mi in menus[i].items) {
				removeChild(mi);
			}
		}
	}

	private function backMenu() : Null<MenuSet> {

		// we can't remove the last level.
		if (menus.length == 1) return null;

		var oldmenu = menus.shift();
		for (mi in oldmenu.items) {
			removeChild(mi);
		}

		// sets the new one.
		for (mi in menus[0].items) {
			addChild(mi);
		}

		return oldmenu;
	}

	private function applySettings() {
		var settings = backMenu();

		for (s in settings.items) {
			if (s.choice != null) {
				trace(s.name);
				if (s.name == "CRT Effect") {
					if (s.choice == "On") Game.instance.setBubbleEffect(true);
					else Game.instance.setBubbleEffect(false);
				} else if (s.name == "Scanlines") {
					if (s.choice == "On") Game.instance.setScanlinesEffect(true);
					else Game.instance.setScanlinesEffect(false);
				}
			}
		}
	}

	public function startGame() {
		while(menus.length > 1) backMenu();
		Game.instance.startGame();
	}
	
	public function keypressed(key : Int) {
		if (Controls.is("down", key)) {

			var selected = menus[0].selected;

			menus[0].items[selected].over = false;

			selected = menus[0].selected += 1;
			if (selected >= menus[0].items.length) selected = menus[0].selected = 0;

			menus[0].items[selected].over = true;

		} else if (Controls.is("up", key)) {

			var selected = menus[0].selected;


			menus[0].items[selected].over = false;

			selected = menus[0].selected -= 1;
			if (selected < 0) selected = menus[0].selected = menus[0].items.length - 1;

			menus[0].items[selected].over = true;

		} else if (Controls.is("confirm", key)) {

			var selected = menus[0].selected;
			menus[0].items[selected].pressed();

		} else if (menus[0].items[menus[0].selected].choice != null && Controls.is("left", key)) {
			menus[0].items[menus[0].selected].moveChoice(-1);
			
		} else if (menus[0].items[menus[0].selected].choice != null  && Controls.is("right", key)) {
			menus[0].items[menus[0].selected].moveChoice(1);
			
		}
	}
}