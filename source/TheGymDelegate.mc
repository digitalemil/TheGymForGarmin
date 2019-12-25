using Toybox.WatchUi;

class TheGymDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new TheGymMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}