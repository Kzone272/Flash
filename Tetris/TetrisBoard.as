package {
	
	import flash.geom.Point;
	import flash.events.EventDispatcher;
	import flash.events.Event;

	public class TetrisBoard extends EventDispatcher {

		public var b:Array = new Array();
		public var Width:int;
		public var Height:int;

		public function TetrisBoard(width:int = 10, height:int = 20) {

			Width = width;
			Height = height;

			//Standard 10 by 20 Tetris board
			for (var i:int = 0; i < width; i++) {

				b[i] = new Array();

				for (var j:int = 0; j < height; j++) {
					b[i][j] = null;
				}
			}

		}

		public function addBlock(xPos:int, yPos:int, Type:String, Num:int = 0, Fallen:Boolean = false):Boolean {
			
			if (b[xPos][yPos] !=null) {
				dispatchEvent(new Event("collision"));
				return false;
			}
			
			b[xPos][yPos] = new Block(Type,Num,Fallen);
			
			return true;
		}

		public function addTetrimino(type:String, xShift:int = 0, yShift:int = 0):void {

			var positions:Array = new Array();

			switch (type) {
				case 'I' :
					positions[0] = [3 + xShift,0 + yShift];
					positions[1] = [4 + xShift,0 + yShift];
					positions[2] = [5 + xShift,0 + yShift];
					positions[3] = [6 + xShift,0 + yShift];
					break;
				case 'O' :
					positions[0] = [4 + xShift,0 + yShift];
					positions[1] = [5 + xShift,0 + yShift];
					positions[2] = [4 + xShift,1 + yShift];
					positions[3] = [5 + xShift,1 + yShift];
					break;
				case 'T' :
					positions[0] = [4 + xShift,0 + yShift];
					positions[1] = [3 + xShift,1 + yShift];
					positions[2] = [4 + xShift,1 + yShift];
					positions[3] = [5 + xShift,1 + yShift];
					break;
				case 'S' :
					positions[0] = [4 + xShift,0 + yShift];
					positions[1] = [5 + xShift,0 + yShift];
					positions[2] = [3 + xShift,1 + yShift];
					positions[3] = [4 + xShift,1 + yShift];
					break;
				case 'Z' :
					positions[0] = [3 + xShift,0 + yShift];
					positions[1] = [4 + xShift,0 + yShift];
					positions[2] = [4 + xShift,1 + yShift];
					positions[3] = [5 + xShift,1 + yShift];
					break;
				case 'J' :
					positions[0] = [3 + xShift,0 + yShift];
					positions[1] = [3 + xShift,1 + yShift];
					positions[2] = [4 + xShift,1 + yShift];
					positions[3] = [5 + xShift,1 + yShift];
					break;
				case 'L' :
					positions[0] = [5 + xShift,0 + yShift];
					positions[1] = [3 + xShift,1 + yShift];
					positions[2] = [4 + xShift,1 + yShift];
					positions[3] = [5 + xShift,1 + yShift];
					break;
			}

			for (var i:int = 0; i < 4; i++) {
				if (! addBlock(positions[i][0], positions[i][1], type, i)) return;
			}

		}

	}

}