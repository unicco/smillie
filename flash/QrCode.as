package {
	import flash.events.*;
	import flash.display.*;	
	import flash.net.*;
	/**
	* ...
	* @author Default
	*/
	public class QrCode extends Sprite {
		private var _ldr:Loader;
		private var _info:XML;
		
		public function QrCode() {
		}
		
		public function init(info:XML) {
			//trace(numChildren);
			if (numChildren == 0){
				_info = info;
				_ldr = new Loader();
				_ldr.load(new URLRequest(_info.@post_qrcode));
				this.x = this.y = 8;
				addChild(_ldr);
			}
		}
	}
}