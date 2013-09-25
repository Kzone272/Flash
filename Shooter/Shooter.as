package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.ui.Mouse;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.filters.BlurFilter;
	import flash.display.DisplayObjectContainer;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	public class Shooter extends MovieClip {
		
		public const levels = 5;
		public var bgScale:Number;
		public var initWidth:Number;
		public var initHeight:Number;
		public var smallGuys:Array = new Array();
		public var largeGuys:Array = new Array();
		public var score:int = 0;
		public var rooftopsBmpData:BitmapData;
		public var timers:Array = new Array();
		public var volumes:Array = new Array();
		public var pans:Array = new Array();
		public var accuracies:Array = new Array();
		public var sniperSound:Sound = new Sound();
		public var deathSound:Sound = new Sound();
		public var distSound:Sound = new Sound;
		public var distChannel:SoundChannel = new SoundChannel();
		public var bgLoop:Sound = new Sound();
		public var bgControl:SoundChannel = new SoundChannel();
		public var redScreen:RedScreen = new RedScreen();
		public var frame:int = 0;
		public var hit:Boolean = false;
		public var enemyTotal = 5;
		public var enemiesAlive;
		public var mute:Boolean = false;
		public var menu:Menu = new Menu;
		public var level:int = 1;
		
		public function Shooter() {
			
			sniperSound.load(new URLRequest("sniperShot.mp3"));
			distSound.load(new URLRequest("distantShot.mp3"));
			deathSound.load(new URLRequest("death.mp3"));
			bgLoop.load(new URLRequest("bgMusic.mp3"));
			
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
			
		public function addedToStage(e:Event):void {
			loaderInfo.addEventListener(Event.COMPLETE, stageLoaded);
		}
		
		public function stageLoaded(e:Event):void {
			
			//Creates the gradient mask for te front background element. (It fades into the next one)
			scopeMaskFaded.cacheAsBitmap = true;
			largeBG.cacheAsBitmap = true;
			largeBG.mask = scopeMaskFaded;
			
			//Sets scale and stuff
			initWidth = largeBG.width;
			initHeight = largeBG.height;
			largeBG.scaleX = largeBG.scaleY = 1/2;
			bgScale = ((largeBG.width - stage.stageWidth) / stage.stageWidth);
			
			largeBG2.scaleX = largeBG2.scaleY = largeBG.scaleX * 1.25;
			
			//Sets up the colour styles for the second background element
			var colour:ColorTransform = new ColorTransform();
			/******White & Blue******/
			colour.redOffset = 120;
			colour.greenOffset = 100;
			colour.blueOffset = 255;
			
			var blur:BlurFilter = new BlurFilter(10, 10, 1);
			largeBG2.filters = [blur];
			largeBG2.transform.colorTransform = colour;
			
			//Creates bitmap data of the rooftops movieclip (This is a bunch of 
			rooftopsBmpData = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0);
			rooftopsBmpData.draw(rooftops);
			rooftops.visible = false;
			
			//Queue music and lights.
			playBgLoop();
			showMenu();
			
			//Mute button clickability
			muteButton.addEventListener(MouseEvent.CLICK, muteClick);
			
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
		
		public function click(e:MouseEvent):void {
			sniperSound.play();
		}
		
		public function muteClick(e:MouseEvent):void {
			//Mutes and unmutes
			if (!mute) {
				mute = true;
				muteButton.gotoAndStop(2);
				bgControl.stop();
			} else if (mute) {
				mute = false;
				muteButton.gotoAndStop(1);
				playBgLoop();
			}
		}
		
		public function newGame():void {
			
			Mouse.hide();
			
			//Clear all arrays
			smallGuys.splice(0, smallGuys.length);
			largeGuys.splice(0, largeGuys.length);
			timers.splice(0, timers.length);
			volumes.splice(0, volumes.length);
			pans.splice(0, pans.length);
			accuracies.splice(0, accuracies.length);
			
			//5 More enemies per level & Reset Enemies Alive
			enemyTotal = 5 * level;
			enemiesAlive = enemyTotal;
			
			//Set score anemeies left fields
			scoreText.text = "Score: " + score;
			enemiesText.text = "Enemies Left: " + enemiesAlive;
			
			//Add Enemies
			for (var i:int = 0; i < enemyTotal; i++) {
				addEnemy(i);
			}
			
			//Event Listeners
			addEventListener(MouseEvent.CLICK, click);
			addEventListener(Event.ENTER_FRAME, enterFrame);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
			
		}
		
		public function enterFrame(e:Event):void {
			
			//All of this is used to move around the background elements
			scope.x = mouseX;
			scope.y = mouseY;
			
			scopeMask.x = mouseX;
			scopeMask.y = mouseY;
			
			scopeMaskFaded.x = mouseX;
			scopeMaskFaded.y = mouseY;
			
			largeBG.x = -1 * mouseX * bgScale;
			largeBG.y = -1 * mouseY * bgScale;
			
			largeBG2.scaleX = largeBG2.scaleY = largeBG.scaleX * 1.15;
			largeBG2.x = -1 * mouseX * (largeBG2.width - stage.stageWidth) / stage.stageWidth;
			largeBG2.y = -1 * mouseY * (largeBG2.width - stage.stageWidth) / stage.stageWidth;
			
			//This removes the red screen when you get hit after 20 frames
			frame++;
			if (frame >= 20 && hit) {
				stage.removeChild(redScreen);
				hit = false;
			}
			
		}
		
		public function mouseWheel(e:MouseEvent):void {
			
			//If you scroll up you zoom in and down you zoom out.
			if (e.delta > 0 && (largeBG.width / stage.stageWidth) < 2.5) {
				
				largeBG.scaleX = largeBG.scaleY *= 1.2;
				bgScale = ((largeBG.width - stage.stageWidth) / stage.stageWidth);
				
			} else if (e.delta < 0){
				
				largeBG.scaleX = largeBG.scaleY /= 1.2;
				
				if ( (largeBG.width / stage.stageWidth) < 1.25) {
					largeBG.scaleX = largeBG.scaleY = stage.stageWidth / initWidth * 1.25;
				}
				
				bgScale = ((largeBG.width - stage.stageWidth) / stage.stageWidth);
				
			}
			
		}
		
		public function addEnemy(num:int):void {
			
			var xPos:Number
			var yPos:Number
			var size:Number
			
			//This loops throught creating a bunch of random x and y positions and checks whether 
			//or not their feet are on the rooftops.  It hittests the rooftops bitmap data I made earlier.
			//I fit doesn't hit the rooftops, then it reapeats.
			do {
				xPos = Math.random()* initWidth;
				yPos = Math.random()* initHeight;
			
				var position:Point = new Point(xPos/3, yPos/3);
			
			} while (! rooftopsBmpData.hitTest(new Point(0, 0) , 0.1, position, new Point(stage.stageWidth, stage.stageHeight)));
			
			size = 0.0003 * yPos + 0.15;
			
			//Adds an enemy to both background elemnts (Main and faded one)
			var smallGuy:Enemy = new Enemy();
			smallGuy.x = xPos;
			smallGuy.y = yPos;
			smallGuy.scaleX = size;
			smallGuy.scaleY = size;
			
			var largeGuy:Enemy = new Enemy();
			largeGuy.x = xPos;
			largeGuy.y = yPos;
			largeGuy.scaleX = size;
			largeGuy.scaleY = size;
			
			//The enemy has two frames, one standing and one crouching.  This choses which one to use.
			var enemyFrame:int = Math.random() * 2 + 1;
			smallGuy.gotoAndStop(enemyFrame);
			largeGuy.gotoAndStop(enemyFrame);
			
			//About 15% of people are left handed, this horzinotally flips 15% of people.
			var lefty:int = Math.random() * 100 + 1;
			if (lefty <= 15) {
				smallGuy.scaleX *= -1;
				largeGuy.scaleX *= -1;
			}
			
			//Add a clcick even listener to them
			largeGuy.addEventListener(MouseEvent.CLICK, enemyHit);
			
			//Starts their shoot timer to between 2 and 10 seconds
			var timer:Timer = new Timer(Math.random() * 8000 + 2000, 0);
			timer.addEventListener(TimerEvent.TIMER, shootTimer);
			timer.start();
			timers[num] = timer;
			//Sets volume of that enemy's shots based on their y position (Distance away from you)
			volumes[num] = (yPos / initHeight);
			//Sets pans based on their x positions
			pans[num] = (2 * (xPos / initWidth)) -1;
			//Sets accuracies of that enemy's shots based on their y position (Distance away from you)
			accuracies[num] = (xPos / initWidth);
			
			//Add the enemies to both background elements
			smallBG.addChild(smallGuy);
			largeBG.addChild(largeGuy);
			
			//Adds them to an array
			smallGuys[num] = smallGuy;
			largeGuys[num] = largeGuy;
			
			
		}
		
		public function enemyHit(e:MouseEvent):void {
			
			//Finds enemy number in the array
			var enemyNum:int = largeGuys.indexOf(e.target);
			
			//Removes him from both background elements
			smallBG.removeChild( smallGuys[enemyNum] );
			largeBG.removeChild( largeGuys[enemyNum] );
			
			//Stops his shoot timer
			timers[enemyNum].stop();
			
			deathSound.play();
			
			//Updates score and enemies left
			score += 100;
			scoreText.text = "Score: " + score;
			
			enemiesAlive--;
			enemiesText.text = "Enemies Left: " + enemiesAlive;
			
			//Checks if sohuld go to the next level and if it should restart the game
			if (enemiesAlive <= 0) {
				level++;
				if (level > levels) {
					//Sets gameover var in showMenu() to true;
					showMenu(true);
					level = 1;
				} else
					showMenu();
			}
			
		}
		
		
		public function shootTimer(e:TimerEvent):void {
			
			//Random time between 2 and 10 seconds
			e.currentTarget.delay = Math.random() * 8000 + 2000;
			
			//Gets timer number in array
			var timerNum:int = timers.indexOf(e.target);
			
			//Calculates whether they hit you based on their distance away from you (y speed)
			if (accuracies[timerNum] >= Math.random() * 2) {
				frame = 0;
				//Adds red screen when yoou get hit
				stage.addChild(redScreen);
				redScreen.gotoAndPlay(1);
				hit = true;
				
				//Lose 25 points
				score -= 25;
				scoreText.text = "Score: " + score;
			}
			
			//Plays muzzle flash
			smallGuys[timerNum].muzzleFlash.gotoAndPlay(1);
			largeGuys[timerNum].muzzleFlash.gotoAndPlay(1);
			
			//Transforms sound based on their x and y positions (pan and volume)
			distChannel = distSound.play();
			distChannel.soundTransform = new SoundTransform(volumes[timerNum], pans[timerNum]);
			
		}
		
		public function showMenu(gameover:Boolean = false):void {
			
			//Event Listeners
			removeEventListener(MouseEvent.CLICK, click);
			removeEventListener(Event.ENTER_FRAME, enterFrame);
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
			
			//Adds menu and shows mouse
			Mouse.show();
			stage.addChild(menu);
			menu.x = stage.stageWidth / 2;
			menu.y = stage.stageHeight / 2;
			
			//Makes a bunch of game stuff invisible
			scoreText.visible = false;
			enemiesText.visible = false;
			muteButton.visible = false;
			scope.visible = false;
			largeBG.visible = false;
			largeBG2.visible = false;
			
			//Different stuff based on whether on not the game is restarting
			if (!gameover) {
				menu.levelText.text = "Level " + level;
				menu.startButton.visible = true;
				menu.startButton.addEventListener(MouseEvent.CLICK, start);
			} else if (gameover) {
				menu.levelText.text = "Your Score Was: " + score;
				menu.startButton.visible = false;
				menu.playAgain.addEventListener(MouseEvent.CLICK, start);
				score = 0;
			}
			
			//Start button click event
			function start(e:MouseEvent):void {
				
				//Makes stage stuff visible again
				scoreText.visible = true;
				enemiesText.visible = true;
				muteButton.visible = true;
				scope.visible = true;
				largeBG.visible = true;
				largeBG2.visible = true;
				
				//Starts new game
				hit = false;
				stage.removeChild(menu);
				newGame();
				
			}
			
		}
		
	}
	
}