package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	
	public class Moles extends MovieClip {
		
		public var holes:Array = new Array();
		public var moles:Array = new Array();
		public var whacked:Array = new Array();
		public var timers:Array = new Array();
		public var newMole:Timer;
		public var newMoles:int = 1;
		public var molesUp:int = 0;
		public var newMoleTime:int = 1500;
		public var moleUpTime:int = 2500;
		public var score:int = 0;
		public var countdown:Timer;
		public var secondsLeft:int = 60;
		public var hammer:Hammer = new Hammer();
		public var hitSound:Sound = new Sound();
		public var bgLoop:Sound = new Sound();
		public var bgControl:SoundChannel = new SoundChannel();
		public var muteBtn:MuteButton = new MuteButton();
		public var muted:Boolean = false;
		public var menu:Menu = new Menu;
		
		public function Moles() {
			
			hitSound.load(new URLRequest("hit.mp3"));
			bgLoop.load(new URLRequest("background.mp3"));
			bgLoop.addEventListener(Event.COMPLETE, soundLoaded);
			
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
			
		public function addedToStage(e:Event):void {
			loaderInfo.addEventListener(Event.COMPLETE, stageLoaded);
		}
		
		public function stageLoaded(e:Event):void {
			//Draw holes
			for (var i:int = 0; i < 3; i++) {
				for (var j:int = 0; j < 3; j++) {
					
					var hole:Hole = new Hole();
					hole.x = i * 175 + 100;
					hole.y = j * 110 + 130;
					hole.scaleX= hole.scaleY = 0.5;
					hole.mole.addEventListener(MouseEvent.MOUSE_DOWN, moleClick);
					stage.addChild(hole);
					holes[i * 3 + j] = hole;
					moles[i * 3 + j] = false;
					whacked[i * 3 + j] = false;
					timers[i * 3 + j] = new Timer(moleUpTime, 1);
					timers[i * 3 + j].addEventListener(TimerEvent.TIMER, moleTimer);
				}
			}
			
			muteBtn.x = 520;
			muteBtn.y = 370;
			stage.addChild(muteBtn);
			muteBtn.addEventListener(MouseEvent.MOUSE_DOWN, muteClick);
			
			menu.x = stage.stageWidth / 2;
			menu.y = 150;
			menu.newGameText.addEventListener(MouseEvent.CLICK, newGameClick);
			stage.addChild(menu);
			
			hammer.mouseChildren = false;
			stage.addChild(hammer);
			
			updateTime();
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stageClick);
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		public function newGameClick(e:MouseEvent):void {
			newGame();
			menu.visible = false;
		}
		
		public function soundLoaded(e:Event):void {
			playBgLoop();
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
		
		public function muteClick(e:MouseEvent):void {
			//Mutes and unmutes
			if (!muted) {
				muted = true;
				muteBtn.gotoAndStop(2);
				bgControl.stop();
			} else if (muted) {
				muted = false;
				muteBtn.gotoAndStop(1);
				playBgLoop();
			}
		}
		
		public function newGame():void {
			
			score = 0;
			secondsLeft = 60;
			newMoleTime = 1500;
			moleUpTime = 2500;
			
			newMole = new Timer(newMoleTime, 0);
			newMole.addEventListener(TimerEvent.TIMER, newMoleEvent);
			newMole.start();
			
			countdown = new Timer(1000, secondsLeft);
			countdown.addEventListener(TimerEvent.TIMER, countdownTimer);
			countdown.addEventListener(TimerEvent.TIMER_COMPLETE, gameOver);
			countdown.start();
			
			updateTime();
			scoreText.text = "Score: " + score;
			
			updateTime();
		}
		
		public function enterFrame(e:Event):void {
			hammer.x = mouseX;
			hammer.y = mouseY;
		}
		
		public function stageClick(e:MouseEvent):void {
			hammer.play();
			hitSound.play();
		}
		
		public function newMoleEvent(e:TimerEvent):void {
			
			for (var i:int = 0; i < newMoles; i++) {
					
				var nextMole:int;
				if (molesUp == 9) break;
				do {
					nextMole = Math.floor(Math.random() * 9);
				} while ( moles[nextMole] );
				
				if (holes[nextMole].currentFrame == 1) {						
					molesUp++;
					moles[nextMole] = true;
					holes[nextMole].gotoAndPlay(1);
					holes[nextMole].mole.gotoAndStop(1);
					whacked[nextMole] = false;
					timers[nextMole].start();
				}
			}
		}
		
		public function moleDown(mole:int = 0):void {
			
			moles[mole] = false;
			holes[mole].gotoAndPlay(24);
			timers[mole].stop();
			whacked[mole] = true;
			molesUp--;
		}
		
		public function moleClick(e:MouseEvent):void {
			
			var currentMole:int = holes.indexOf(e.target.parent);
			
			if (! whacked[currentMole]) {
				
				score += 10;
				scoreText.text = "Score: " + score;
				
				if (score % 50 == 0)
					levelUp();
				
				moleDown(currentMole);
				holes[currentMole].mole.gotoAndStop(2);
			}
		}
		
		public function moleTimer(e:TimerEvent):void {
			moleDown( timers.indexOf(e.target) );
		}
		
		public function countdownTimer(e:TimerEvent):void{
			secondsLeft--;
			updateTime();
		}
		
		public function updateTime():void {
			
			var minutes:int = secondsLeft / 60;
			var seconds:int = secondsLeft % 60;
			timeText.text = "Time: " + minutes + ":";
			
			var sec:String = String(seconds);
			while (sec.length < 2)
				sec = "0" + sec;
			timeText.text += sec;
		}
		
		public function levelUp():void {
			//every 5 moles
			if (newMoleTime > 250)
				newMoleTime -= 250;
			
			//every 10 moles
			if (score % 100 == 0) {
				if (newMoles < 3)
					newMoles++;
				if (moleUpTime > 500)
					moleUpTime -= 500;
			}
		}
		
		public function gameOver(e:TimerEvent):void {
			
			newMole.stop();
			
			for (var i:int = 0; i < 9; i++) {
				if (! whacked[i]) {
					moleDown(i);
					whacked[i] = true;
				}
			}
			
			scoreText.text = "Score: " + score;
			
			menu.visible = true;
		}
		
	}
	
}
