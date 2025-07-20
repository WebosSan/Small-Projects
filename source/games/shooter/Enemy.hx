package games.shooter;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;

class Enemy extends FlxSprite
{
	public var speed:Float = 225;
	public var target:FlxSprite;

	public var isAlive:Bool = true;

	private var _sineWave:Float = 0;

	public function new()
	{
		super();
		loadGraphic(AssetPaths.sEnemy__png, true, 40, 40);

		// im to lazy
		animation.add("idle", [6], 12, true);
		animation.add("walk", [for (i in 0...7) i], 12, true);
		animation.add("dead", [7], 16, true);

		animation.play("idle");

		scale.set(2, 2);
		updateHitbox();
		antialiasing = true;
		screenCenter();

		width -= 30;
		height -= 30;
		centerOffsets();
	}

	// why
	public function heydudethisguyisgettingkilled()
	{
		isAlive = false;

		var targetCenterX = target.x + target.width / 2;
		var targetCenterY = target.y + target.height / 2;
		var myCenterX = x + width / 2;
		var myCenterY = y + height / 2;

		var pushDirection = new FlxPoint(myCenterX - targetCenterX, myCenterY - targetCenterY);
		pushDirection.normalize();

		/*
			== perdon por el español ==
			son las 11 de la mañana, estoy haciendo efectos para un enemigo en vez de dormir
			ya no tengo ganas de especificar los tipos en mis variables, tengo sueño xd
		 */

		var initialForce = 400;
		velocity.set(pushDirection.x * initialForce, pushDirection.y * initialForce);

		animation.play("dead", true);

		FlxFlicker.flicker(this, 1, 0.04, true, true, f ->
		{
			kill();
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		_sineWave += 0.1;

		if (Manager.initialized && !Manager.isDead)
		{
			if (isAlive)
			{
				animation.play("walk");
				flipX = (target.x + target.width / 2) < (x + width / 2);
				FlxVelocity.moveTowardsObject(this, target, speed);
			}
			else
			{
				velocity.x = FlxMath.lerp(velocity.x, 0, 0.2);
				velocity.y = FlxMath.lerp(velocity.y, 0, 0.2);
			}
		} else {
			FlxFlicker.flicker(this, 0.1, 0.04, true, false);
			y += Math.sin(_sineWave);
		}
	}
}
