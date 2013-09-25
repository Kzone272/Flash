package  {	
	
	public class Particle extends Projectile {
		
		public function Particle():void {
			
			//Max Speed, Min Speed, and Angle, are all contructor paramters in the projectile class.
			super(5, 3, Math.random() * 360)
			
		}
		
	}
	
}
