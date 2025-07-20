package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.typeLimit.NextState;

class Chooser extends FlxState
{
	var title:FlxText;
	var selector:FlxText;

	var curSelected(default, set):Int = 0;

	var sineUtil:Float;

	var minigames:Array<
		{
			name:String,
			state:NextState,
			description:String
		}> = [
			{
				name: "Top Down Shooter",
				state: games.shooter.Manager.initRound(),
				description: "Beat Hordes of enemies, survive 10 rounds, if you can"
			}
		];

	var texts:Array<FlxText> = [];

	override function create()
	{
		super.create();

		title = new FlxText(0, 40, 0, "Choose a Minigame", 40);
		title.screenCenter(X);
		title.antialiasing = false;
		add(title);

		for (i in 0...minigames.length)
		{
			trace(minigames[i].name);
			var minigame:FlxText = new FlxText(40, FlxG.height / 2 + (40 * i), 0, minigames[i].name, 20);
			minigame.antialiasing = false;
			add(minigame);
			texts.push(minigame);
		}

		selector = new FlxText(0, 0, 0, ">", 20, false);
		add(selector);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

        curSelected += Input.getStrength(S, W);

		sineUtil += 0.01;

		title.angle += Math.sin(sineUtil * 5) / 10;

		selector.x = (texts[curSelected].x - selector.width - 5) + Math.sin(sineUtil * 5) * 5;
		selector.y = texts[curSelected].y + (texts[curSelected].height - selector.height) / 2;

		for (i in 0...texts.length)
		{
			var text:FlxText = texts[i];
			text.color = FlxColor.interpolate(text.color, (curSelected == i ? FlxColor.YELLOW : FlxColor.WHITE), 0.5);
		}

        if (FlxG.keys.justPressed.ENTER){
            FlxG.switchState(minigames[curSelected].state);
        }
	}

	function set_curSelected(v:Int):Int
	{
		if (v == 0)
			return curSelected;

		curSelected = v;
		if (curSelected < 0)
		{
			curSelected = texts.length - 1;
		}
		else if (curSelected >= texts.length)
		{
			curSelected = 0;
		}
		return curSelected;
	}
}
