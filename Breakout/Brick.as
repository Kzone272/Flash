package  {
	
	import flash.display.MovieClip;
	import flash.display.Graphics;
	
	public class Brick extends MovieClip {
		
		public var colour:uint;
		public var bWidth:Number;
		public var bHeight:Number;
		public var theStage:MovieClip;
		
		public function Brick(theStage = null, bWidth = 50, bHeight = 15, colour = 0xFFFFFF) {
			
			update(bWidth, bHeight, colour);
			
		}
		
		public function update(bWidth, bHeight, colour):void {
			
			graphics.clear();
			graphics.beginFill(colour);
			graphics.drawRoundRect(-bWidth/2, -bHeight/2, bWidth, bHeight, bHeight/1.5, bHeight/1.5);
			graphics.endFill();
			
		}
		
	}
	
}
