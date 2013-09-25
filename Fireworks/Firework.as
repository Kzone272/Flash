package {
	
	import flash.geom.Rectangle;
	import flash.filters.GlowFilter;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import fl.transitions.Tween;
	import fl.transitions.easing.*
	import flash.geom.ColorTransform;
	
	public class Firework extends Projectile {
		
		protected var stageRectangle:Rectangle;
		public var firechildren:Array = new Array();
		public var exploded:Boolean = false;
		public var colour:uint;
		private var explodeTimer:Timer;
		
		public function Firework(stageRect:Rectangle, col:uint = 0xFF0000) {
			
			super(12, 15, Math.random() * 50 - 115 );
			draw(3, col);
			stageRectangle = stageRect;
			colour = col;
			
			explodeTimer = new Timer(Math.random() * 300 + 300, 1);
			explodeTimer.addEventListener(TimerEvent.TIMER, explodeTimerEvent);
			explodeTimer.start();
			
		}
		
		public function explode():void {
			
			exploded = true;
			graphics.clear();
			
			var red:uint = colour / 0x10000;
			var green:uint = (colour % 0x10000) / 0x100;;
			var blue:uint = (colour % 0x100);
			
			if (red < 0xff) red += 0x20;
			if (green < 0xff) green += 0x20;
			if (blue < 0xff) blue += 0x20;
			
			var col:uint = (red * 0x10000) + (green * 0x100) + blue;
			
			for (var i:int = 0; i < 50; i++) {
				
				var fc:Firechild = new Firechild(stageRectangle, col);
				fc.x = x;
				fc.y = y;
				fc.filters = [new GlowFilter(col, 0.5, 6, 6, 4, 2)];
				var fade:Tween = new Tween(fc, "alpha", Strong.easeOut, 100, 0, 0.8, true);
				stage.addChild(fc);
				
				firechildren.push(fc);
				
			}
			
		}
		
		public function explodeTimerEvent(e:TimerEvent):void {
			
			explodeTimer.stop();
			if (!exploded) explode();
			
		}
		
		public function moveAll():void {
			
			move();
			
			for (var i:int = 0; i < firechildren.length; i++) {
				firechildren[i].move();
				
				var rectangle:Rectangle = new Rectangle(-10, -10, stage.stageWidth+10, stage.stageHeight+10);
				if (! stageRectangle.contains(firechildren[i].x, firechildren[i].y) || firechildren[i].alpha == 0) {
					stage.removeChild(firechildren[i]);
					firechildren.splice(i, 1);
					i--;
				}
			}
			
		}
		
	}
	
}