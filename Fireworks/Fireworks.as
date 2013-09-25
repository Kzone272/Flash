package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.filters.GlowFilter;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	
	public class Fireworks extends MovieClip {
		
		public var fwTimer:Timer;
		public var fireworks:Array = new Array();
		public var stageRectangle:Rectangle;
		public var bgLoop:Sound = new Sound();
		public var bgControl:SoundChannel = new SoundChannel();
		public var pausePoint:Number = 0.00;
		public var muteBtn:MuteButton = new MuteButton();
		public var muted:Boolean = false;
		
		public function Fireworks() {
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
			
		public function addedToStage(e:Event):void {
			
			bgLoop.load(new URLRequest("Firework.mp3"));
			bgLoop.addEventListener(Event.COMPLETE, soundLoaded);
			
			stageRectangle = new Rectangle(-10, -10, stage.stageWidth+10, stage.stageHeight+10);
			
			fwTimer = new Timer(400, 0);
			fwTimer.addEventListener(TimerEvent.TIMER, fwTimerEvent);
			fwTimer.start();
			
			muteBtn.x = 520;
			muteBtn.y = 370;
			stage.addChild(muteBtn);
			muteBtn.addEventListener(MouseEvent.CLICK, muteClick);
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
			stage.addEventListener(MouseEvent.CLICK, clickStage);
		}
		
		public function soundLoaded(e:Event):void {
			playBgLoop();
		}
		
		public function playBgLoop():void {
			//Plays bg music and adds a listener for when it stops:
			bgControl = bgLoop.play(pausePoint);
			bgControl.addEventListener(Event.SOUND_COMPLETE, bgLoopEnd);
		}
		
		public function bgLoopEnd(e:Event):void {
			//Resets bg music:
			pausePoint = 0.00;
			playBgLoop();
		}
		
		public function muteClick(e:MouseEvent):void {
			//Mutes and unmutes
			if (!muted) {
				muted = true;
				muteBtn.gotoAndStop(2);
				pausePoint = bgControl.position;
				bgControl.stop();
			} else if (muted) {
				muted = false;
				muteBtn.gotoAndStop(1);
				playBgLoop();
			}
		}
		
		public function enterFrame(e:Event):void {
			
			for (var i:int = 0; i < fireworks.length; i++) {
				fireworks[i].moveAll();
				
				if ( (! stageRectangle.contains(fireworks[i].x, fireworks[i].y) && ! fireworks[i].exploded) ||
					(fireworks[i].exploded && fireworks[i].firechildren.length == 0) ) {
					stage.removeChild(fireworks[i]);
					fireworks[i].exploded = true;
					fireworks.splice(i, 1);
					i--;
				}
			}
		}
		
		public function fwTimerEvent(e:TimerEvent):void {
			
			newFirework();
		}
		
		public function newFirework():void {
			
			//Colours that are saturated and nice.
			var colours:Array = new Array();
			var brightest:int = Math.random() * 3;
			colours[brightest] = 0xff;
			
			var nextCol:int;
			do {
				nextCol = Math.random() * 3;
			} while (nextCol == brightest);
			
			colours[nextCol] = int((Math.random() * 2)) * 0x7f;
			colours[3 - brightest - nextCol] = 0;
			
			var colour:uint = (0x10000 * colours[0]) + (0x100 * colours[1]) + colours[2];
			
			var fw:Firework = new Firework(stageRectangle, colour);
			fw.x = Math.random() * (stage.stageWidth - 100) + 50;
			fw.y = stage.stageHeight;
			fw.filters = [new GlowFilter(colour, 0.5, 10, 10, 5, 3)];
			stage.addChild(fw);
			
			fireworks.push(fw);
		}
		
		public function clickStage(e:MouseEvent):void {
			newFirework();
		}
		
	}
	
}
