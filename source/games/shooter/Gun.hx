package games.shooter;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;

class Gun extends FlxSprite
{
    public var target:FlxSprite;
    public var orbitRadius:Float = 40;
    public var rotateSpeed:Float = 0.2;
    public var faceMouse:Bool = true;
    
    private var _currentAngle:Float = 0;
    private var _targetAngle:Float = 0;
    private var _previousMouseAngle:Float = 0;
    private var _rotationCount:Int = 0;
    
    public function new() 
    {
        super();
        loadGraphic(AssetPaths.sGun__png);

        scale.set(2, 2);
        updateHitbox();
        antialiasing = true;
        screenCenter();

        width -= 12;
        height -= 12;
        centerOffsets();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        if (target != null)
        {
            updateOrbitPosition();
            updateRotation();
        }
    }

    private function updateOrbitPosition():Void
    {
        var targetCenterX = target.x + target.width/2;
        var targetCenterY = target.y + target.height/2;
        
        var newMouseAngle = Math.atan2(
            FlxG.mouse.y - targetCenterY,
            FlxG.mouse.x - targetCenterX
        );
        
        if (Math.abs(newMouseAngle - _previousMouseAngle) > Math.PI)
        {
            if (newMouseAngle > _previousMouseAngle) {
                _rotationCount--;
            } else {
                _rotationCount++;
            }
        }
        
        _targetAngle = newMouseAngle + (_rotationCount * 2 * Math.PI);
        _previousMouseAngle = newMouseAngle;
        
        x = targetCenterX + Math.cos(newMouseAngle) * orbitRadius - width/2;
        y = targetCenterY + Math.sin(newMouseAngle) * orbitRadius - height/2;
    }

    private function updateRotation():Void
    {
        if (faceMouse)
        {
            _currentAngle = FlxMath.lerp(_currentAngle, _targetAngle, rotateSpeed);
            
            var degrees = _currentAngle * 180/Math.PI;
            angle = degrees % 360;
            
            flipY = (angle > 90 || angle < -90);
        }
    }

    override public function destroy():Void
    {
        super.destroy();
    }

    public function getShootPoint():FlxPoint
    {
        var radius = width / 2;
        var shootPoint = FlxPoint.get(
            x + width/2 + Math.cos(_currentAngle) * radius,
            y + height/2 + Math.sin(_currentAngle) * radius
        );
        trace(shootPoint);
        return shootPoint;
    }
}