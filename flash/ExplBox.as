package {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.events.*;
	
	/**
	* ...
	* @author Default
	*/
	public class ExplBox extends Sprite {
		private var _info:XML;
		
		public function ExplBox() {
			this.visible = false;
		}
		
		public function init(_info:XML) {
			this.adrs.text = _info.@post_address;
			this.visible = true;
			
			this.stage.addEventListener(Event.RESIZE, setSize);
			setSizeXY();
		}
		
		private function setSize(evt:Event) {
			setSizeXY();
		}
		
		private function setSizeXY() {
			this.x = 10;
			this.y = this.stage.stageHeight - this.height - 10;
		}
	}
	
}