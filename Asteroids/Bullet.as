package  {
	
	public class Bullet extends Projectile {
		
		public var life:int = 0;
		public var maxLife = 50;
		
		public function Bullet(speed:Number, angle:Number):void {
			
			//Max Speed and Min Speed are the same. The angle is the ships angle.
			super(speed, speed, angle);
			
		}
		
	}
	
}
