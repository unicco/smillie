package {
	
	import flash.display.*;
	import flash.text.*;
	
	/**
	* ...
	* @author Default
	*/
	public class LoadingCnt extends Sprite {
		
		public function LoadingCnt() {
		}
		
		public function setNo(cnt:Number, total:Number, ratio:Number) {
			_desc.text = ratio + "%";
			_no.text = cnt + "/" + total;
		} 
	}
	
}