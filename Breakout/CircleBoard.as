package {
	
	import flash.display.MovieClip;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class CircleBoard extends MovieClip {
		
		private var colour:uint;
		private var offset:Number;
		private var dotsWide:int;
		private var dotsHigh:int;
		private var dots:Array = new Array();
		private var focus:MovieClip;
		
		public function CircleBoard(foc:MovieClip, col:uint = 0xFFFFFF, size = 1, boardWidth = 550, boardHeight = 400):void {
			
			dotsWide = Math.ceil(boardWidth / (50 * size));
			dotsHigh = Math.ceil(boardHeight / (50 * size));
			colour = col;
			offset = size
			focus = foc;
			drawBoard();
			addEventListener(Event.ENTER_FRAME, enterFrame);
			
		}
		
		private function enterFrame(e:Event):void {
			
			var pos:Point = new Point();
			
			if (focus != null) {
				pos.x = focus.x - x;
				pos.y = focus.y - y;
			} else {
				pos.x = mouseX;
				pos.y = mouseY;
			}
			
			for (var i:int = 0; i < dotsWide; i++) {
				
				for (var j:int = 0; j < dotsHigh; j++) {
					
					var dist = Math.sqrt(Math.pow(pos.x-dots[i][j].x, 2) + Math.pow(pos.y-dots[i][j].y, 2));
					var scale = -1/18000 * Math.pow(dist+25,2) + 1;
					
					if (scale > 1)
						scale = 1;
					else if (scale < 0)
						scale = 0;
						
					dots[i][j].scaleX = dots[i][j].scaleY = scale * offset;
					dots[i][j].alpha = scale;
					
				}
				
			}
			
		}
		
		private function drawBoard():void {
			
			for (var i:int = 0; i < dotsWide; i++) {
				
				dots[i] = new Array();
				
				for (var j:int = 0; j < dotsHigh; j++) {
					
					var dot:MovieClip = new MovieClip();
					dot.graphics.beginFill(colour);
					dot.graphics.drawCircle(0, 0, 25);
					dot.graphics.endFill();
					addChild(dot);
					
					dot.x = i * 50 * offset + 25 * offset;
					dot.y = j * 50 * offset + 25 * offset;
					
					dots[i][j] = dot;
					
				}
				
			}
			
		}
		
	}
	
}
