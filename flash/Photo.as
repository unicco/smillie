package {
	import flash.display.*;
	import flash.events.*;
	import flash.filters.BlurFilter;
	import flash.net.*;
	import flash.text.TextField;
	import caurina.transitions.*;
	
	/**
	* ...
	* @author Kansai Takako
	*/
	public class Photo extends Sprite {
		
		private var _info:XML;
		private var _ldr:Loader;
		private var _link:String;
		private var _orgPhotoX:Number;
		private var _orgPhotoY:Number;
		private var _orgHoldX:Number;
		private var _orgHoldY:Number;
		private var _orgStageWidth:Number;
		private var _orgStageHeight:Number;
		private var _endX:Number;
		private var _endY:Number;
		private var _phCount:Number;
		private var _ldPhCount:Number;//static しないと呼び出されるたびに 0 になる
		
		public function Photo() {
		}
		
		public function init(info:XML, phCount:Number, ldCount:Number) {
			_orgStageWidth = this.stage.stageWidth;
			_orgStageHeight = this.stage.stageHeight;
			_phCount = phCount;
			_ldPhCount = ldCount;
			
			_info = info;
			_ldr = new Loader();
			_ldr.load(new URLRequest(_info.@link));
			_ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, ldCompHandler);
			_ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(evt:Event) { trace("load err"); } );
			this.bildeHolder.addChild(_ldr);
			
			// 時間を抽出
			var pattern:RegExp = /(\d\d:\d\d:\d\d)/; 
			var dateStr:String = _info.@date;
			var textStr:String = dateStr.substr(dateStr.search(pattern), 8);
			this.txt.text = textStr;
		}
		
		private function ldCompHandler(evt:Event) {
			//写真の配置
			with (this.bildeHolder) {
				if (height > width) {
					_orgPhotoY = height;
					height = 455;
					width = width * height / _orgPhotoY;
					x += (455 - width) / 2;
				} else {
					_orgPhotoX = width;
					width = 455;
					height = height * width / _orgPhotoX;
					y += (455 - height) / 2;
				}
			}
			
			this.scaleX = this.scaleY = 0.3;
			this.rotation = (1/2 - Math.random()) * 100;
			filters = new Array(new BlurFilter(1, 1));
			
			//ここで最終着地点を決める
			_orgHoldX = _endX = Math.random() * (this.stage.stageWidth - this.width) + this.width * 0.7;
			_orgHoldY = _endY = (this.stage.stageHeight - 200 - this.height) * Math.random() + 170;
			Tweener.addTween(this, { x: _endX, y:_endY, time:1, delay:0 } );
			
			this.stage.addEventListener(Event.RESIZE, setSize);
			
			if (_ldPhCount + 1 == _phCount) {
				Main.getInstance().onCompShowPhoto();
			}
			_ldr.contentLoaderInfo.removeEventListener(Event.COMPLETE, ldCompHandler);
		}
		
		private function setSize(evt:Event) {
			setSizeXY();
		}
		
		private function setSizeXY() {
			this.x = PhotoScreen.getInstance().stage.width * _orgHoldX / _orgStageWidth;
			this.y = PhotoScreen.getInstance().stage.height * _orgHoldY / _orgStageHeight;
			_orgHoldX = this.x;
			_orgHoldY = this.y;
			_orgStageWidth = PhotoScreen.getInstance().stage.width;
			_orgStageHeight = PhotoScreen.getInstance().stage.height;
		}
	}	
}
