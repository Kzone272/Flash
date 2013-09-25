package  {
	
	import flash.display.MovieClip;
	import flash.display.Graphics;
	
	public class Ball extends MovieClip{
		
		public var colour:uint;
		public var radius:Number;
		public var theStage:MovieClip
		
		public function Ball(theStage = null, radius = 7.5, colour = 0xFFFFFF):void {
			
			update(radius, colour);
			
		}
		
		public function update(radius, colour):void {
			
			graphics.clear();
			graphics.beginFill(colour);
			graphics.drawCircle(0, 0, radius);
			graphics.endFill();
			
		}

	}
	
}