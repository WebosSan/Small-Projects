package games.shooter;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
	var wallOffset:Float = 30;
	var walls:FlxSprite;
	var gun:Gun;
	var player:Player;
	var bullets:FlxTypedGroup<Bullet>;
	var stamina:Float = 100;
	var maxStamina:Float = 100;
	var staminaDrainRate:Float = 33.3;
	var staminaRegenRate:Float = 20;
	var staminaBar:FlxSprite;
	var healthBar:FlxSprite;
	var barWidth:Int;
	var health:Int = 5;
	var damageTimer:Float = 1;
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
	var gameOverText:FlxText;
	var restartText:FlxText;
	var gameOverGroup:FlxTypedGroup<FlxSprite>;
	var gameOverBg:FlxSprite;

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

		barWidth = Std.int(FlxG.width / 3);
		var barHeight = 20;
		var cornerRadius = 20;

		var staminabarborder = FlxSpriteUtil.drawRoundRect(new FlxSprite().makeGraphic(barWidth, barHeight, FlxColor.TRANSPARENT), 0, 0, barWidth, barHeight,
			cornerRadius, cornerRadius, FlxColor.TRANSPARENT, {
				thickness: 10,
				color: FlxColor.BLACK
			});
		staminabarborder.updateHitbox();
		staminabarborder.antialiasing = true;
		staminabarborder.scrollFactor.set();
		staminabarborder.y = FlxG.height - staminabarborder.height - 20;
		staminabarborder.x = (FlxG.width / 2) + 10;

		var healthBarBorder = FlxSpriteUtil.drawRoundRect(new FlxSprite().makeGraphic(barWidth, barHeight, FlxColor.TRANSPARENT), 0, 0, barWidth, barHeight,
			cornerRadius, cornerRadius, FlxColor.TRANSPARENT, {
				thickness: 10,
				color: FlxColor.BLACK
			});
		healthBarBorder.updateHitbox();
		healthBarBorder.antialiasing = true;
		healthBarBorder.scrollFactor.set();
		healthBarBorder.y = FlxG.height - healthBarBorder.height - 20;
		healthBarBorder.x = (FlxG.width / 2) - healthBarBorder.width - 10;

		ammoText = new FlxText(0, 0, 0, "6 / 6", 16);
		ammoText.antialiasing = true;
		ammoText.setBorderStyle(OUTLINE, FlxColor.BLACK, 3, 0);
		ammoText.screenCenter(X);
		ammoText.y = staminabarborder.y - ammoText.height - 20;
		ammoText.scrollFactor.set();
		add(ammoText);

		staminaBar = new FlxSprite(staminabarborder.x + 10, staminabarborder.height + 10);
		staminaBar.makeGraphic(barWidth - 10, barHeight, 0xFFFFFFFF);
		staminaBar.antialiasing = true;
		staminaBar.scrollFactor.set();
		staminaBar.x = staminabarborder.x + 5;
		staminaBar.y = staminabarborder.y;
		staminaBar.color = 0xFF95FFA9;
		add(staminaBar);
		add(staminabarborder);

		healthBar = new FlxSprite(healthBarBorder.x + 10, healthBarBorder.height + 10);
		healthBar.makeGraphic(barWidth - 10, barHeight, 0xFFFFFFFF);
		healthBar.antialiasing = true;
		healthBar.scrollFactor.set();
		healthBar.x = healthBarBorder.x + 5;
		healthBar.y = healthBarBorder.y;
		healthBar.color = 0xFFFF8F8F;
		add(healthBar);
		add(healthBarBorder);

		timerText = new FlxText(0, 0, 0, "3", 65);
		timerText.screenCenter();
		timerText.scrollFactor.set();
		timerText.setBorderStyle(OUTLINE, FlxColor.BLACK, 3, 0);
		add(timerText);

		gameOverGroup = new FlxTypedGroup<FlxSprite>();
		add(gameOverGroup);

		gameOverBg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		gameOverBg.alpha = 0;
		gameOverGroup.add(gameOverBg);

		gameOverText = new FlxText(0, 0, FlxG.width, "GAME OVER", 48);
		gameOverText.setFormat(null, 48, FlxColor.RED, CENTER, OUTLINE, FlxColor.BLACK);
		gameOverText.screenCenter();
		gameOverText.alpha = 0;
		gameOverGroup.add(gameOverText);

		restartText = new FlxText(0, 0, FlxG.width, "Press ENTER to restart", 24);
		restartText.setFormat(null, 24, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		restartText.screenCenter();
		restartText.y += 100;
		restartText.alpha = 0;
		gameOverGroup.add(restartText);

		gameOverGroup.visible = false;

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
		if (!Manager.isDead)
		{
			timerText.alpha = FlxMath.lerp(timerText.alpha, 0, 0.035);
			timerText.y = FlxMath.lerp(timerText.y, FlxG.height, 0.05);
			timerText.angle = FlxMath.lerp(timerText.y, 45, 0.05);
		}
		if (Manager.initialized && !Manager.isDead)
		{
			damageTimer = (damageTimer - elapsed).clamp(0, 1);
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 0.8, 0.1);

			var playerBounds:FlxPoint = new FlxPoint();
			playerBounds.x = Math.max(walls.x + wallOffset, Math.min(player.x, (walls.x + walls.width) - wallOffset * 1.8));
			playerBounds.y = Math.max(walls.y + wallOffset, Math.min(player.y, (walls.y + walls.height) - wallOffset * 1.8));
			player.setPosition(playerBounds.x, playerBounds.y);

			updateStamina(elapsed);
			updateStaminaBar();

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

			ammoText.color = FlxColor.interpolate(ammoText.color, (ammo <= 0 ? 0xFFEA5959 : FlxColor.WHITE));
			ammoText.updateHitbox();
			ammoText.screenCenter(X);

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

			for (enemy in enemies)
			{
				if (player.overlaps(enemy) && damageTimer <= 0)
				{
					health = Std.int((health - 1).clamp(0, 5));
					damageTimer = 2;
					FlxG.camera.zoom = 1;
					player.color = FlxColor.RED;
				}
			}

			if (damageTimer > 0)
			{
				FlxFlicker.flicker(player, 0.1, 0.04, true, false);
			}

			updateHealthBar();

			if (enemies.length <= 0 && timerText.text != "Done")
			{
				timerText.text = "Done";
				timerText.alpha = 1;
				timerText.angle = 0;
				timerText.updateHitbox();
				timerText.screenCenter();
				new FlxTimer().start(0.75, tmr -> FlxG.switchState(Manager.initRound()));
			}
			Manager.isDead = health == 0;
		}
		if (Manager.isDead)
		{
			gameOverGroup.visible = true;
			gameOverBg.alpha = FlxMath.lerp(gameOverBg.alpha, 0.7, 0.1);
			gameOverText.alpha = FlxMath.lerp(gameOverText.alpha, 1, 0.1);
			restartText.alpha = FlxMath.lerp(restartText.alpha, 1, 0.1);

			player.velocity.set(0, 0);
			player.screenCenter();

			if (FlxG.keys.justPressed.ENTER)
			{
				Manager.isDead = false;
				Manager.initialized = false;
				health = 5;
				FlxG.resetState();
			}
		}

		player.color = FlxColor.interpolate(player.color, FlxColor.WHITE, 0.15);
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
		staminaBar.scale.x = staminaPercentage;
		staminaBar.origin.set(0, 0);

		if (staminaPercentage < 0.2)
		{
			staminaBar.color = 0xFFFE9797;
		}
		else if (staminaPercentage < 0.5)
		{
			staminaBar.color = 0xFFF7FE97;
		}
		else
		{
			staminaBar.color = 0xFF95FFA9;
		}
	}

	function updateHealthBar()
	{
		var staminaPercentage = health / 5;
		healthBar.scale.x = staminaPercentage;
		healthBar.origin.set(0, 0);

		healthBar.color = 0xFFFF8F8F;

		if (staminaPercentage < 0.2)
		{
			healthBar.color.lightness -= 0.3;
		}
		else if (staminaPercentage < 0.5 && staminaPercentage > 0.7)
		{
			healthBar.color.lightness -= 0.2;
		}
	}
}