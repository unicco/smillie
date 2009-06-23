package {
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.filters.GradientBevelFilter;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.*;
	
	/**
	* ...
	* @author Default
	*/
	public class LiquidBG extends Sprite {
				
		private var _glow:GlowFilter = new GlowFilter();
		
		public function LiquidBG() {
		}
		
		public function init() {
			drawBG();
			drawGlow();
			this.stage.addEventListener(Event.RESIZE, setSize);
		}
		
		private function setSize(evt:Event) {
			drawBG();
			drawGlow();
		}
		
		private function drawBG() {
			this.graphics.clear();
			this.graphics.beginBitmapFill(new bgBitmap(0, 0), null, true, true);
			this.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight);
			this.graphics.endFill();
		}
		
		private function drawGlow() {
			_glow.color = 0x333333;
			_glow.alpha = 1;
			_glow.blurX = 100;
			_glow.blurY = 150;
			_glow.inner = true;
			_glow.strength = 1.5;
			_glow.quality = BitmapFilterQuality.MEDIUM;
			this.filters = [_glow];
		}
	}
	
}