 package actors.brain;

 import flixel.tweens.FlxEase;
 import flixel.tweens.FlxTween;
 import flixel.math.FlxVelocity;
 import flixel.FlxG;
 import flixel.FlxObject;
 import flixel.FlxSprite;
 import flixel.math.FlxPoint;
 import actors.brain.FSM;
 import actors.Player;

  
 class Monster extends FlxSprite
 {
    public var range:Float = 0;
    var _brain:FSM;
    var _idleTmr:Float;
    var _moveDir:Float;
   
    public var seesPlayer:Bool = false;
    public var rememberPlayerPos:Bool = false;
    public var playerPos(default, null):FlxPoint;
    public var speed:Float = 100;
    
    public var Damage:Float;
    public var etype(default, null):Int;
    
    public function new(?X:Float=0, ?Y:Float=0, EType:Int)
    {
        super(X, Y);
        etype = EType;
        loadGraphic("assets/images/enemy-" + etype + ".png", true, 16, 16);
        setFacingFlip(FlxObject.LEFT, false, false);
        setFacingFlip(FlxObject.RIGHT, true, false);
        animation.add("d", [0, 1, 0, 2], 6, false);
        animation.add("lr", [3, 4, 3, 5], 6, false);
        animation.add("u", [6, 7, 6, 8], 6, false);
        drag.x = drag.y = 10; //drag is a value that determines how quickly the body will slowdown
        width = 8;
        height = 14;
        offset.x = 4;
        offset.y = 2;
        _brain = new FSM(idle);
        _idleTmr = 0;
        playerPos = FlxPoint.get();
        health = 100; 
    }

    override public function draw():Void
    {
        if ((velocity.x != 0 || velocity.y != 0 ) && touching == FlxObject.NONE)
        {
            if (Math.abs(velocity.x) > Math.abs(velocity.y))
            {
                if (velocity.x < 0)
                    facing = FlxObject.LEFT;
                else
                    facing = FlxObject.RIGHT;
            }
            else
            {
                if (velocity.y < 0)
                    facing = FlxObject.UP;
                else
                    facing = FlxObject.DOWN;
            }

            switch (facing)
            {
                case FlxObject.LEFT, FlxObject.RIGHT:
                    animation.play("lr");

                case FlxObject.UP:
                    animation.play("u");

                case FlxObject.DOWN:
                    animation.play("d");
            }
        }
        super.draw();
    }

    public function findPlayer(p:Player):Void
    {   
        var cat1:Float = p.x - this.x;
        var cat2:Float = p.y - this.y;
        var distance:Float = Math.sqrt((cat2 *cat2) + (cat1 * cat1));
        this.attackRange(distance);
    }

    public function attackRange(d:Float):Void
    { 
        if (d < 10)//10 это растояние на какйо длинне запускаетсья процесс 
        {
           //Должна вызываться функция нанесения урона
        }
    }

    public function takeDamage():Void
    {
        this.health =  this.health - Damage;

        if (health <= 0)
        {
            this.kill();
        }

    }
    
    public function idle():Void
    {
        if (seesPlayer)
        {
            _brain.activeState = chase;

        }
        else if (_idleTmr <= 0)
        {
            if (FlxG.random.bool(1))
            {
                _moveDir = -1;
                velocity.x = velocity.y = 0;
            }
            else
            {
                _moveDir = FlxG.random.int(0, 8) * 45;

                velocity.set(speed * 0.3, 0);
                velocity.rotate(FlxPoint.weak(), _moveDir);
                
            }
            _idleTmr = FlxG.random.int(1, 4);            
        }
        else
            _idleTmr -= FlxG.elapsed;

    }

    public function chase():Void
    {
        if (!seesPlayer)
        {
            _brain.activeState = idle;
        }
        else
        {
            FlxVelocity.moveTowardsPoint(this, playerPos, Std.int(speed));
        }
    }
        
    override public function update(elapsed:Float):Void
    {   
        super.update(elapsed);
        _brain.update();
    }
}