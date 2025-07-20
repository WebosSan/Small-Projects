package utils;

import flixel.FlxG;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;

class Input {
    public static function getStrength(keyA:FlxKey, keyB:FlxKey, ?state:FlxInputState = PRESSED) {
        var keyAInt:Int = FlxG.keys.checkStatus(keyA, state) ? 1 : 0;
        var keyBInt:Int = FlxG.keys.checkStatus(keyB, state) ? 1 : 0;

        return keyAInt - keyBInt;
    }
}