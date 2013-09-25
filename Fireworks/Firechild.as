package {
	
	import flash.geom.Rectangle;
	
	public class Firechild extends Projectile {
		
		public var stageRectangle:Rectangle;
		
		public function Firechild(stageRect:Rectangle, colour:uint) {
			
			super(5, 8, Math.random() * 360 );
			draw(1.5, colour);
			stageRectangle = stageRect;
			
		}
		
	}
	
}