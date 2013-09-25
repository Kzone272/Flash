package  {
	
	import flash.display.MovieClip;
	import flash.display.ShaderInput;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class Asteroids extends MovieClip {
		
		public var ship:Ship = new Ship();
		public var dir:String;
		public var forward:Boolean;
		public var backward:Boolean;
		public var xSpd:Number = 0;
		public var ySpd:Number = 0;
		public var maxSpd:Number = 6;
		public var friction:Number = -0.3;
		public var rotSpd:Number = 0;
		public var rotMax:Number = 6;
		public var bullets:Array = new Array();
		public var bulletSpd:Number = 10;
		public var shooting:Boolean;
		public var interval:int = 0;
		public var asteroids:Array = new Array();
		public var frame:int = 0;
		public var shootSound:Sound = new Sound();
		public var explodeSound:Sound = new Sound();
		public var bgLoop:Sound = new Sound();
		public var bgControl:SoundChannel = new SoundChannel();
		public var score:int;
		public var lives:int;
		public var scoreText:TextField = new TextField();
		public var mainTf:TextFormat = new TextFormat();
		public var subTf:TextFormat = new TextFormat();
		public var leftTf:TextFormat = new TextFormat();
		public var livesText:TextField = new TextField();
		public var tCenter:TextField = new TextField();
		public var tSub:TextField = new TextField();
		public var astCount:int = 10;
		public var menu:Menu = new Menu();
		public var classic:Boolean;
		public var endless:Boolean;
		public var infinite:Boolean;
		public var paused:Boolean;
		public var dead:Boolean;
		
		public function Asteroids():void {
			
			//Load sounds:
			shootSound.load(new URLRequest("shoot.mp3"));
			explodeSound.load(new URLRequest("explosion.mp3"));
			bgLoop.load(new URLRequest("backgroundMusic.mp3"));
			
			//Create text formats:
			mainTf.font = "Visitor TT1 BRK";
			mainTf.align = "center";
			mainTf.size = 48;
			mainTf.color = 0xFFFFFF;
			
			leftTf.font = "Visitor TT1 BRK";
			leftTf.align = "left";
			leftTf.size = 48;
			leftTf.color = 0xFFFFFF;
			
			subTf.font = "Visitor TT1 BRK";
			subTf.align = "center";
			subTf.size = 24;
			subTf.color = 0xFFFFFF;
			
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
			
		public function addedToStage(e:Event):void {
			this.loaderInfo.addEventListener(Event.COMPLETE, loaded);
		}
		
		public function loaded(e:Event):void {
			playBgLoop();
			showMenu();
		}
		
		public function showMenu():void {
			
			menu.x = stage.stageWidth / 2;
			menu.y = 275;
			stage.addChild(menu);
			
			menu.classicBtn.addEventListener(MouseEvent.CLICK, classicClick);
			menu.endlessBtn.addEventListener(MouseEvent.CLICK, endlessClick);
			menu.infiniteBtn.addEventListener(MouseEvent.CLICK, infiniteClick);
			
		}
		
		public function classicClick(e:Event):void {
			newLevel(0);
		}
		public function endlessClick(e:Event):void {
			newLevel(1);
		}
		public function infiniteClick(e:Event):void {
			newLevel(2);
		}
		
		public function newLevel(type:int):void {
			
			//Add score and lives textfields:		
			scoreText.x = 10;
			scoreText.y = 2;
			scoreText.width = 350;
			scoreText.height = 48;
			scoreText.selectable = false;
			scoreText.setTextFormat(mainTf);
			stage.addChild(scoreText);
			
			livesText.x = stage.stageWidth - 205;
			livesText.y = 2;
			livesText.width = 200;
			livesText.height = 48;
			livesText.selectable = false;
			livesText.setTextFormat(mainTf);
			stage.addChild(livesText);
			
			switch(type) {
				case 0:
					classic = true;
					endless = false;
					infinite = false;
					lives = 2;
					astCount = 5;
					break;
				case 1:
					endless = true;
					classic = false;
					infinite = false;
					lives = 3;					
					astCount = 10;
					break;
				case 2:
					infinite = true;
					classic = false;
					endless = false;
					lives = 1;
					astCount = 7;
					break;
			}
			
			removeAsts();
			removeBullets();
			score = 0;
			dead = false;
			
			//Create asteroids:
			for (var i:int = 0; i < astCount; i++) {
				newAst();
			}
			
			menu.classicBtn.removeEventListener(MouseEvent.CLICK, classicClick);
			menu.endlessBtn.removeEventListener(MouseEvent.CLICK, endlessClick);
			menu.infiniteBtn.removeEventListener(MouseEvent.CLICK, infiniteClick);
			stage.removeChild(menu);
			
			resetLevel();
			
		}
		
		public function resetLevel(newLevel:Boolean = false):void {
			
			updateText();
			
			//Reset ship's position:
			ship.x = stage.stageWidth / 2;
			ship.y = stage.stageHeight / 2;
			ship.rotation = 0;
			ship.gotoAndStop("thrustOff");
			stage.addChild(ship);
			
			//Set all ship movement variables to default:
			forward = false;
			backward = false;
			dir = "";
			rotSpd = 0;
			xSpd = 0;
			ySpd = 0;
			
			
			//Create new asteroids (classic mode):
			if (newLevel) {
				for (var i:int = 0; i < astCount; i++) {
					newAst();
				}
			}
			
			//Event Listeners:
			stage.addEventListener(Event.ENTER_FRAME, enterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			
		}
		
		public function playBgLoop():void {
			
			//Plays bg music and adds a listener for when it stops:
			bgControl = bgLoop.play();
			bgControl.addEventListener(Event.SOUND_COMPLETE, bgLoopEnd);
			
		}
		
		public function bgLoopEnd(e:Event):void {
			
			//Resets bg music:
			playBgLoop();
			
		}
		
		public function updateText():void {
		
			scoreText.text = "Score: " + String(score);
			scoreText.setTextFormat(leftTf);
			
			livesText.text = "Lives: " + String(lives);
			livesText.setTextFormat(leftTf);
		}
		
		public function keyDown(e:KeyboardEvent):void {
						
			if (e.keyCode == Keyboard.LEFT)
				dir = "ccw";
			if (e.keyCode == Keyboard.RIGHT)
				dir = "cw";
			if (e.keyCode == Keyboard.UP) {
				forward = true;
				ship.gotoAndStop("thrustOn");
			}
			if (e.keyCode == Keyboard.DOWN)
				backward = true;
			if (e.keyCode == Keyboard.SPACE)
				shooting = true;
		
		}
		
		public function keyUp(e:KeyboardEvent):void {
			
			if (e.keyCode == Keyboard.LEFT && dir == "ccw" && !paused)
				dir = "";
			if (e.keyCode == Keyboard.RIGHT && dir == "cw" && !paused)
				dir = "";
			if (e.keyCode == Keyboard.UP && !paused) {
				forward = false;
				ship.gotoAndStop("thrustOff");
			}
			if (e.keyCode == Keyboard.DOWN && !paused)
				backward = false;
			if (e.keyCode == Keyboard.SPACE && !paused)
				shooting = false;
			if (e.keyCode == Keyboard.SPACE && paused) {
				pause();
				resetLevel();
			}
			if (e.keyCode == Keyboard.P)
				pause();
			
		}
		
		public function enterFrame(e:Event):void {
			
			move();
			if (!dead) {
				astHitTest();
				shipHitTest();
				bulletMove();
			}
			astMove();
			
			frame++;
			if (frame % 250 == 0 && !classic && !infinite)
				newAst();
			
		}
		
		public function pause(text:String = "PAUSED", textSub:String = ""):void {
			
			if (!paused) {
				
				paused = true;
				stage.removeEventListener(Event.ENTER_FRAME, enterFrame);
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
				
				tCenter.text = text;
				tCenter.selectable = false;
				tCenter.width = 550;
				tCenter.height = 60;
				tCenter.x = stage.stageWidth/2 - tCenter.width/2;
				tCenter.y = 270 - tCenter.height/2;
				tCenter.setTextFormat(mainTf);
				stage.addChild(tCenter);
				
				tSub.text = textSub;
				tSub.selectable = false;
				tSub.width = 550;
				tSub.height = 60;
				tSub.x = stage.stageWidth/2 - tSub.width/2;
				tSub.y = 325 - tCenter.height/2;
				tSub.setTextFormat(subTf);
				stage.addChild(tSub);
				
			}else if (paused) {
				
				stage.removeChild(tCenter);
				stage.removeChild(tSub);
				
				paused = false;
				stage.addEventListener(Event.ENTER_FRAME, enterFrame);
				stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
				
				if (dead) {
					showMenu();
				}
				
			}
			
		}
		
		
		public function move():void {
			
			//Rotation acceleration:
			if (dir == "cw" && rotSpd < rotMax)
				rotSpd += 1;
			else if (dir == "ccw" && rotSpd > -rotMax)
				rotSpd -= 1;
			
			//Rotation friction:
			if (dir == "") {
				if (Math.abs(rotSpd) < 1/2)		//<-- To prevent the ship from rotating
					rotSpd =0;					//extremely small amounts when it
				else if (rotSpd > 0)			//should be stopped.
					rotSpd -= 1/2
				else if (rotSpd < 0)
					rotSpd += 1/2;
			}
			
			//Applying rotation:
			ship.rotation += rotSpd;
			
			//Friction:
			if (Math.abs(xSpd) > 0)
				xSpd += friction * (xSpd / Math.abs(xSpd)) * (Math.abs(xSpd) / (Math.abs(xSpd) + Math.abs(ySpd)));
			if (Math.abs(ySpd) > 0)
				ySpd += friction * (ySpd / Math.abs(ySpd)) * (Math.abs(ySpd) / (Math.abs(xSpd) + Math.abs(ySpd)));
			
			//Calculating forward acceleration:
			if (forward && Math.sqrt(Math.pow(xSpd,2) + Math.pow(ySpd,2)) < maxSpd) {
				xSpd += maxSpd * Math.cos(ship.rotation / 180 * Math.PI) / 12;
				ySpd += maxSpd * Math.sin(ship.rotation / 180 * Math.PI) / 12;
			}
			
			//Calculating backward acceleration:
			if (backward && Math.sqrt(Math.pow(xSpd,2) + Math.pow(ySpd,2)) < maxSpd / 1.5) {
				xSpd -= maxSpd * Math.cos(ship.rotation / 180 * Math.PI) / 15;
				ySpd -= maxSpd * Math.sin(ship.rotation / 180 * Math.PI) / 15;
			}
			
			//Preventing the ship from moving extremely small amounts when it should be stopped:
			if (Math.sqrt(Math.pow(xSpd,2) + Math.pow(ySpd,2)) < 0.1) {
				xSpd = 0;
				ySpd = 0;
			}
			
			//Wrapping the ship around the stage:
			if (ship.x > stage.stageWidth + 10)
				ship.x = -10;
			if (ship.x < -10)
				ship.x = stage.stageWidth + 10;
			if (ship.y > stage.stageHeight + 10)
				ship.y = -10;
			if (ship.y < -10)
				ship.y = stage.stageHeight + 10;
			
			//Applying x and y speed:
			ship.x += xSpd;
			ship.y += ySpd;
			
			//Shooting intervals (You can only shoot about 3 second):
			interval++;
			if (shooting && interval >= 15) {
				shoot();
				interval = 0;
			}
			
		}
		
		public function shoot() {
			
			if (dead)
				return;
			
			shootSound.play();
			
			var bullet:Bullet = new Bullet(bulletSpd, ship.rotation);
			bullet.xSpd += xSpd;
			bullet.ySpd += ySpd;
			bullet.x = ship.x + (Math.cos(ship.rotation / 180 * Math.PI) * 15);
			bullet.y = ship.y + (Math.sin(ship.rotation / 180 * Math.PI) * 15);
			stage.addChild(bullet);
			
			bullets.push(bullet);
			
		}
		
		public function bulletMove() {
			
			for (var i:int = bullets.length - 1; i >= 0; i--) {
				
				//Wrapping bullets around the stage:
				if (bullets[i].x > stage.stageWidth + 10)
					bullets[i].x = -10;
				if (bullets[i].x < -10)
					bullets[i].x = stage.stageWidth + 10;
				if (bullets[i].y > stage.stageHeight + 10)
					bullets[i].y = -10;
				if (bullets[i].y < -10)
					bullets[i].y = stage.stageHeight + 10;
				
				bullets[i].move();
				
				//Bullets only last 100 frames (2 seconds):
				bullets[i].life++;
				
				if (bullets[i].life > bullets[i].maxLife) {
					stage.removeChild(bullets[i]);
					bullets.splice(i, 1);
				}
				
			}
			
		}
		
		public function removeBullets() {
			
			for (var i:int = bullets.length - 1; i >= 0; i--) {
				stage.removeChild(bullets[i]);
				bullets.splice(i, 1);
			}
			
		}
		
		public function shipHitTest():void {
			
			for (var i:int = asteroids.length - 1; i >= 0; i--) {
				
				if (asteroids[i].astHit.hitTestObject(ship)) {
					
					var particles:Particles = new Particles();
					particles.x = asteroids[i].x;
					particles.y = asteroids[i].y;
					stage.addChild(particles);
					
					stage.removeChild(asteroids[i]);
					asteroids.splice(i,1);
					shipDie();
					break;
					
				}
				
			}
			
		}
		
		public function newAst(generation:int = 1, pos:Point = null):void {
			
			var ast:Asteroid = new Asteroid(new Point(0,0), new Point(stage.stageWidth, stage.stageHeight), generation);
			stage.addChild(ast);
			if (pos != null) {
				ast.x = pos.x;
				ast.y = pos.y;
			}
			asteroids.push(ast);
			
		}
		
		public function astMove() {
			
			for (var i:int = asteroids.length - 1; i >= 0; i--) {
				
				//Wrapping asteroids around the stage:
				if (asteroids[i].x > stage.stageWidth + 50)
					asteroids[i].x = -50;
				if (asteroids[i].x < -50)
					asteroids[i].x = stage.stageWidth + 50;
				if (asteroids[i].y > stage.stageHeight + 50)
					asteroids[i].y = -50;
				if (asteroids[i].y < -50)
					asteroids[i].y = stage.stageHeight + 50;
				
				//The move function is in the projectile class:
				asteroids[i].move();
				//And the rotate function is only in the asteroid class:
				asteroids[i].rotate();
				
				
			}
			
		}
		
		public function astHitTest():void {
			
			for (var i:int = bullets.length - 1; i >= 0; i--) {
				
				for (var j:int = asteroids.length - 1; j >= 0; j--) {
					
					if (asteroids[j].astHit.hitTestObject(bullets[i])) {
						
						var generation:int = asteroids[j].generation;
						var pos:Point = new Point(asteroids[j].x, asteroids[j].y)
						
						var particles:Particles = new Particles();
						particles.x = pos.x;
						particles.y = pos.y;
						stage.addChild(particles);
						
						explodeSound.play();
						
						score += 10;
						updateText();
						
						stage.removeChild(asteroids[j]);
						asteroids.splice(j,1);
						
						stage.removeChild(bullets[i]);
						bullets.splice(i,1);
						
						if (generation < 3 || infinite) {
							newAst(generation + 1, pos);
							newAst(generation + 1, pos);
						}
						
						if (asteroids.length <= 0 && classic) {
							astCount += 2;
							resetLevel(true);
							pause("Next Level!", "Press The Spacebar To Continue");
						}
						
						break;
						
					}
					
				}
				
			}
			
		}
		
		public function removeAsts():void {
			
			for (var i:int = asteroids.length - 1; i >= 0; i--) {
				
				var particles:Particles = new Particles();
				particles.x = asteroids[i].x;
				particles.y = asteroids[i].y;
				stage.addChild(particles);
				
				explodeSound.play();
				
				stage.removeChild(asteroids[i]);
				asteroids.splice(i, 1);
				
			}
			
		}
		
		public function shipDie():void {
			
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			
			ship.gotoAndPlay("dead");
			dir = "";
			forward = false;
			shooting = false;
			xSpd /= 2;
			ySpd /= 2;
			explodeSound.play();
			
			lives--;
			updateText();
			endLevel();
			
		}
		
		public function endLevel():void {
			
			if (lives > 0)
				pause("You Died!", "Press The Spacebar To Continue");
			else if (lives <= 0) {
				removeAsts();
				removeBullets();
				pause("You Lose", "Press The SPacebar To Go To The Menu");
				dead = true;
			}
			
		}
		
	}
	
}