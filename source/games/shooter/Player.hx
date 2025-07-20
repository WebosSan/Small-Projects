package games.shooter;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.math.FlxMath;

class Player extends FlxSprite
{
	public final speed:Float = 200;
	public var canRun:Bool = true;
	public var running:Bool = false;

	private var speedMultiplier:Float = 1;

	private var xVel:Float = 0;
	private var yVel:Float = 0;

	private var _sineWave:Float = 0;

	public function new()
	{
		super();
		loadGraphic(AssetPaths.sPlayer__png, true, 40, 40);

		animation.add("idle", [0, 1, 2, 3], 12, true);
		animation.add("walk", [4, 5, 6, 7, 8, 9, 10], 12, true);
		animation.add("run", [4, 5, 6, 7, 8, 9, 10], 16, true);

		animation.play("idle");

		scale.set(2, 2);
		updateHitbox();
		antialiasing = true;
		screenCenter();

		width -= 30;
		height -= 30;
		centerOffsets();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		_sineWave += 0.1;

		if (Manager.initialized && !Manager.isDead)
		{
			running = FlxG.keys.pressed.SHIFT;

			speedMultiplier = FlxMath.lerp(speedMultiplier, (running && canRun ? 2 : 1), 0.1);

			xVel = FlxMath.lerp(xVel, Input.getStrength(D, A), 0.1);
			yVel = FlxMath.lerp(yVel, Input.getStrength(S, W), 0.1);

			velocity.x = speed * xVel * speedMultiplier;
			velocity.y = speed * yVel * speedMultiplier;

			if (Math.abs(velocity.x) >= 60 || Math.abs(velocity.y) >= 60)
			{
				animation.play(running && canRun ? "run" : "walk");
			}
			else
			{
				animation.play("idle");
			}
		}
		else
		{
			FlxFlicker.flicker(this, 0.1, 0.04, true, false);
		}

		flipX = FlxG.mouse.x < (x + width / 2);
	}
}
