package {
	
	public class HitTestBox {
		
		public var targetX:Number;
		public var targetY:Number;
		public var targetUp:Number;
		public var targetDown:Number;
		public var targetLeft:Number;
		public var targetRight:Number;
		public var hitUp:Number;
		public var hitDown:Number;
		public var hitLeft:Number;
		public var hitRight:Number;
		
		public function HitTestBox():void {
			
			//Nothing;
			
		}
		
		public function hitTest(targetX, targetY, targetUp, targetDown, targetLeft, targetRight,
								   hitUp, hitDown, hitLeft, hitRight):String {
			
			if (targetDown >= hitUp && targetDown <= hitDown && targetX >= hitLeft && targetX <= hitRight)
				return "up";
			else if (targetUp <= hitDown && targetUp >= hitUp && targetX >= hitLeft && targetX <= hitRight)
				return "down";
			else if (targetRight >= hitLeft && targetRight <= hitRight && targetY > hitUp && targetY < hitDown)
				return "left";
			else if (targetLeft <= hitRight && targetLeft >= hitLeft && targetY > hitUp && targetY < hitDown)
				return "right";
			else
				return "";
			
		}
		
	}
	
}