package games.shooter;

import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;

class Bullet extends FlxSprite
{
	public var piercing:Int = 1;
	public function new(x:Float, y:Float)
	{
		super(x, y);
		loadGraphic(AssetPaths.sBullet__png);
		scale.set(2, 2);
		updateHitbox();
		antialiasing = true;
		screenCenter();

		width -= 12;
		height -= 12;
		centerOffsets();
	}

    //changed,.... instead of using a point just use the angle
	public function goTo(angle:Float)
	{
		velocity.set(Math.cos(angle * FlxAngle.TO_RAD) * 800, Math.sin(angle * FlxAngle.TO_RAD) * 800);

		new FlxTimer().start(10, tmr ->
		{
			kill();
			visible = false;
			destroy();
		});
	}
}
