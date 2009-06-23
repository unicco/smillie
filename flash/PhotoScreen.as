package {
	import flash.display.Sprite;
	/**
	* ...
	* @author Default
	*/
	public class PhotoScreen extends Sprite {
		private static var _myObj:PhotoScreen;
		
		public function PhotoScreen() {
			_myObj = this; //自分自身を子から呼び出すため
		}
		public function init() {
		}
		
		public static function getInstance():PhotoScreen {
			return _myObj;
		}
	}
}