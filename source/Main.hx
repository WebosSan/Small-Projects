package;

import flixel.FlxGame;
import games.shooter.PlayState;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, Chooser));
	}
}
