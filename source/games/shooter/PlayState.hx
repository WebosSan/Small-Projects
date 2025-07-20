package games.shooter;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
	// Walls Collision
	var wallOffset:Float = 30;
	var walls:FlxSprite;
	var gun:Gun;
	var player:Player;

	var bullets:FlxTypedGroup<Bullet>;

	var stamina:Float = 100;
	var maxStamina:Float = 100;
	var staminaDrainRate:Float = 33.3; // per second (100/3)
	var staminaRegenRate:Float = 20; // per second (100/5)
	var bar:FlxSprite;
	var barWidth:Int;

	var shouldSpawn:Bool = true;
	var spawnAmount:Int = 5;

	var ammo:Int = 6;
	var maxAmmo:Int = 6;

	var gameTimer:Int = 3;

	var ammoTimer:FlxTimer;

	var ammoText:FlxText;
	var timerText:FlxText;

	var spawnBounds:Array<Float> = [];

	var enemies:Array<Enemy> = [];

	override function create()
	{
		super.create();
		var bg:FlxBackdrop = new FlxBackdrop();
		bg.loadGraphic(AssetPaths.sBg__png);
		bg.antialiasing = true;
		add(bg);

		var map:FlxSprite = new FlxSprite();
		map.loadGraphic(AssetPaths.sMap__png);
		map.scale.set(2, 2);
		map.updateHitbox();
		map.antialiasing = true;
		map.screenCenter();

		add(map);

		add(gun = new Gun());
		add(player = new Player());
		gun.target = player;

		add(walls = new FlxSprite());
		walls.loadGraphic(AssetPaths.sWall__png);
		walls.scale.set(2, 2);
		wallOffset *= walls.scale.x;
		walls.updateHitbox();
		walls.antialiasing = true;
		walls.screenCenter();

		add(bullets = new FlxTypedGroup());

		barWidth = Std.int(FlxG.width / 1.5);
		var barHeight = 20;
		var cornerRadius = 20;

		var barBorder = FlxSpriteUtil.drawRoundRect(new FlxSprite().makeGraphic(barWidth, barHeight, FlxColor.TRANSPARENT), 0, 0, barWidth, barHeight,
			cornerRadius, cornerRadius, FlxColor.TRANSPARENT, {
				thickness: 10,
				color: FlxColor.BLACK
			});
		barBorder.updateHitbox();
		barBorder.antialiasing = true;
		barBorder.scrollFactor.set();
		barBorder.screenCenter(X);
		barBorder.y = FlxG.height - barBorder.height - 20;

		ammoText = new FlxText(0, 0, 0, "6 / 6", 16);
		ammoText.antialiasing = true;
		ammoText.setBorderStyle(OUTLINE, FlxColor.BLACK, 3, 0);
		ammoText.screenCenter(X);
		ammoText.y = barBorder.y - ammoText.height - 20;
		ammoText.scrollFactor.set();
		add(ammoText);

		bar = new FlxSprite(barBorder.x + 10, barBorder.height + 10);
		bar.makeGraphic(barWidth - 10, barHeight, 0xFFFFFFFF);
		bar.antialiasing = true;
		bar.scrollFactor.set();
		bar.screenCenter(X);
		bar.y = barBorder.y;
		add(bar);
		add(barBorder);

		timerText = new FlxText(0, 0, 0, "3", 65);
		timerText.screenCenter();
		timerText.scrollFactor.set();
		timerText.setBorderStyle(OUTLINE, FlxColor.BLACK, 3, 0);
		add(timerText);

		new FlxTimer().start(1, tmr ->
		{
			gameTimer--;
			timerText.text = Std.string(gameTimer);
			timerText.alpha = 1;
			timerText.angle = 0;
			timerText.updateHitbox();
			timerText.screenCenter();

			if (gameTimer == 0)
			{
				Manager.initialized = true;
			}
		}, 3);

		spawnBounds = [
			walls.x + wallOffset,
			(walls.x + walls.width) - wallOffset * 1.8,
			walls.y + wallOffset,
			(walls.y + walls.height) - wallOffset * 1.8
		];

		FlxG.camera.follow(player);

		spawnEnemies();
	}

	function spawnEnemies()
	{
		if (shouldSpawn)
		{
			for (i in 0...spawnAmount + (2 * (Manager.currentRound - 1)))
			{
				var enemy:Enemy = new Enemy();
				enemy.target = player;
				enemy.setPosition(FlxG.random.float(spawnBounds[0], spawnBounds[1]), FlxG.random.float(spawnBounds[2], spawnBounds[3]));
				add(enemy);
				enemies.push(enemy);
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		timerText.alpha = FlxMath.lerp(timerText.alpha, 0, 0.035);
		timerText.y = FlxMath.lerp(timerText.y, FlxG.height, 0.05);
		timerText.angle = FlxMath.lerp(timerText.y, 45, 0.05);
		if (Manager.initialized)
		{
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 0.8, 0.1);

			var playerBounds:FlxPoint = new FlxPoint();

			playerBounds.x = Math.max(walls.x + wallOffset, Math.min(player.x, (walls.x + walls.width) - wallOffset * 1.8));
			playerBounds.y = Math.max(walls.y + wallOffset, Math.min(player.y, (walls.y + walls.height) - wallOffset * 1.8));

			player.setPosition(playerBounds.x, playerBounds.y);

			updateStamina(elapsed);
			updateStaminaBar();

			// Ammo stuff
			if (FlxG.mouse.justPressed)
			{
				if (ammo > 0)
				{
					var pos = gun.getShootPoint();
					var mousePos = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);

					var bullet:Bullet = new Bullet(pos.x, pos.y);
					bullet.setPosition(pos.x - bullet.width / 2, pos.y - bullet.height / 2);
					bullet.goTo(gun.angle);
					bullets.add(bullet);

					ammo--;
				}
			}

			// FINALLY A CLAMP FUNCTION
			ammo = Std.int(ammo.clamp(0, maxAmmo));

			if (ammo <= 0)
			{
				if (ammoTimer == null)
				{
					ammoTimer = new FlxTimer();
					ammoTimer.start(2.5, tmr ->
					{
						ammo = 6;
						tmr.cancel();
						ammoTimer = null;
					});
					ammoText.text = "Reloading";
				}
			}
			else
			{
				ammoText.text = '$ammo / $maxAmmo';
			}

			// soo if the player is out of ammo the text will become red, if not the text will be white
			ammoText.color = FlxColor.interpolate(ammoText.color, (ammo <= 0 ? 0xFFEA5959 : FlxColor.WHITE));

			ammoText.updateHitbox();
			ammoText.screenCenter(X);

			// ended ammo stuff

			bullets.forEachAlive(function(bullet:Bullet)
			{
				var enemiesKilled:Array<Enemy> = enemies.filter(e -> bullet.overlaps(e));
				var enemyCounter:Int = 0;
				for (i in 0...Std.int(bullet.piercing.clamp(0, enemiesKilled.length)))
				{
					var enemy:Enemy = enemiesKilled[i];

					enemy.heydudethisguyisgettingkilled();
					enemies.remove(enemy);
					remove(enemy);
					enemy.destroy();

					enemyCounter++;
					if (enemyCounter >= bullet.piercing)
					{
						bullet.kill();
						bullets.remove(bullet);
						bullet.destroy();
					}
				}
			});

			if (enemies.length <= 0 && timerText.text != "Done")
			{
				timerText.text = "Done";
				timerText.alpha = 1;
				timerText.angle = 0;
				timerText.updateHitbox();
				timerText.screenCenter();
				new FlxTimer().start(0.75, tmr -> FlxG.switchState(Manager.initRound()));
			}
		}
	}

	function updateStamina(elapsed:Float)
	{
		if (player.running && player.canRun)
		{
			stamina -= staminaDrainRate * elapsed;
		}
		else
			
		{
			stamina += staminaRegenRate * elapsed;
		}

		// TODO: im to lazy to make a Clamp Function
		stamina = Math.max(0, Math.min(stamina, maxStamina));

		if (stamina <= 0)
		{
			player.canRun = false;
		}
		else if (stamina >= maxStamina * 0.2)
		{
			player.canRun = true;
		}
	}

	function updateStaminaBar()
	{
		var staminaPercentage = stamina / maxStamina;
		bar.scale.x = staminaPercentage;
		bar.origin.set(0, 0);

		if (staminaPercentage < 0.2)
		{
			bar.color = 0xFFFE9797;
		}
		else if (staminaPercentage < 0.5)
		{
			bar.color = 0xFFF7FE97;
		}
		else
		{
			bar.color = 0xFF95FFA9;
		}
	}
}
