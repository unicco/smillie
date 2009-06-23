package {
	import flash.display.Sprite;
	import flash.display.*;
	import flash.text.TextField;
	import flash.events.*;
	
	/**
	* ...
	* @author Default
	*/
	public class PhotoCount extends Sprite {
		private var nnumber:Number;
		private var n3:Number;
		private var n2:Number;
		private var n1:Number;
		
		public function PhotoCount() {
		}
		
		public function init() {
			this.stage.addEventListener(Event.RESIZE, setSize);
			setSizeXY();
		}
		
		//ここを public にすると Main から _phCount.updateCount とかで呼べる
		public function updateCount(num:Number) {
			//各桁を分解して配列に入れる
			nnumber = num;
			n3 = Math.floor(nnumber / 100);
			n2 = Math.floor((nnumber - n3 * 100) / 10);
			n1 = nnumber%10;
			this.n000.gotoAndStop(n3 + 1);
			this.n00.gotoAndStop(n2 + 1);
			this.n0.gotoAndStop(n1 + 1);
		}
		
		523
		
		private function setSize(evt:Event) {
			setSizeXY();
		}
		
		private function setSizeXY() {
			this.x = this.stage.stageWidth - this.width;
			this.y = this.stage.stageHeight - this.height;
		}
	}
}