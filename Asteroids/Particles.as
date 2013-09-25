package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Particles extends MovieClip {

		private var particles:Array = new Array();
		private var frame:int = 0;
		
		public function Particles():void {
			
			//Create 10 Particles:			
			for (var i:int = 0; i < 10; i++) {
				
				var part:Particle = new Particle();
				addChild(part);
				particles.push(part);
				
			}
			
			//One enter frame listener for each particles instance isn't too bad.
			addEventListener(Event.ENTER_FRAME, enterFrame);
			
		}
		
		private function enterFrame(e:Event):void {
			
			//Moving particles is easy because of the move function they
			//inherit from the projectile class.
			for (var i:int = particles.length-1; i >= 0; i--) {
				particles[i].move();
			}
			
			//Particles stay on screen for 15 frames:
			frame++;
			if (frame > 15)
				die();
			
		}
		
		private function die():void {
			
			//Remove particles:
			for (var i:int = particles.length-1; i >= 0; i--) {
				this.removeChild(particles[i]);
			}
			
			//Remove event listener and itself:
			removeEventListener(Event.ENTER_FRAME, enterFrame);
			parent.removeChild(this);
			
		}

	}
	
}
