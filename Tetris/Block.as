package  {
	
	public class Block {

		public var type:String;
		public var fallen:Boolean = false;
		public var num:int;

		public function Block(Type:String, Num:int, Fallen:Boolean = false) {
			type = Type;
			num = Num;
			fallen = Fallen;
		}

	}
	
}
