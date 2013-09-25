package  {
	
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	public class Asteroid extends Projectile {
		
		private var rotSpd = Math.random() * 6 - 3;
		public var generation:int;
		
		public function Asteroid(topLeft:Point, bottomRight:Point, gen:int = 1, maxSpd:Number = 3, minSpd:Number = 0):void {
			
			//Max Speed, Min Speed, and Angle of the asteroid controlled
			//by the projectile class which the asteroid extends.
			super(maxSpd, minSpd, Math.random() * 360);
			
			//Goes to one of the ten different asteroid frames:
			var frame:int = Math.random() * 10 + 1;
			gotoAndStop(frame);
			astHit.visible = false;
			
			//Sets the public variable so external members can access it:
			generation = gen;
			//Using an exponential function the calculate the scale, based on the generation:
			scaleX = scaleY = Math.pow(1/2, gen-1);
			
			//Slows down the asteoroids of younger generations so a small asteroid
			//wont spawn and fly into you at ridiculous speeds:
			if(gen > 1) {
				xSpd /= gen / 1.5;
				ySpd /= gen / 1.5;
			}
			
			//Creates a rectangle that asteroids wont spawn:
			var safety:Rectangle = new Rectangle(topLeft.x - 100, topLeft.y - 100,
												 bottomRight.x-topLeft.x+100, bottomRight.y-topLeft.y+100);
			
			//Declaring variables in this scope:
			var xPos:Number;
			var yPos:Number;
			
			//This bit creates a random position, making sure it doesn't
			//fit within the safety box by using a do while loop:
			do {
				xPos = Math.random() * (safety.width + 100) - 50;
				yPos = Math.random() * (safety.height + 100) - 50;
			} while (safety.contains(xPos, yPos));
			
			x = xPos;
			y = yPos;
			
			rotation = Math.random() * 360;
			
			
		}
		
		public function rotate():void {
			
			//Simliar to the projectile's move fucntion, it's just nice to have it
			//contained within its own class.
			rotation += rotSpd;
			
		}
		
	}
	
} 