package games.shooter;

import flixel.util.typeLimit.NextState;

class Manager {
    public static var initialized:Bool = false;
	public static var isDead:Bool = false;
    public static var currentRound:Int = 0;

    public static function initRound():NextState {
		Manager.isDead = false;
        currentRound++;
        initialized = false;
        return PlayState.new;
    }
}