package  {
	
	import flash.display.MovieClip;
	
	public class Projectile extends MovieClip {
		
		//These are public in case you want to change their speed after creation.
		// (This was used to make the bullets inherit the speed of the ship.)
		public var xSpd:Number;
		public var ySpd:Number;
		
		public function Projectile(maxSpd:Number, minSpd:Number, angle:Number):void {
			
			//Calculating random speed between max and min:
			var speed:Number = Math.random() * (maxSpd - minSpd) + minSpd;
			
			//Calculating x and y speeds:
			xSpd = speed * Math.cos(angle / 180 * Math.PI);
			ySpd = speed * Math.sin(angle / 180 * Math.PI);
			
			//Setting the initial rotation of the projectile:
			rotation = angle;
			
		}
		
		public function move():void {
			
			//Nice to have this on all classes that extend this one.
			x += xSpd;
			y += ySpd;
			
		}

	}
	
}
