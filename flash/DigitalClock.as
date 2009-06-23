package {
	
	/**
	* ...
	* @author Default
	*/
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.MovieClip;

	public class DigitalClock extends Sprite {
		
		//コンストラクタ
		function DigitalClock() {
			addEventListener(Event.ENTER_FRAME, updateDigiClock);
		}
		
		//時計を更新する
		function updateDigiClock(event:Event):void {
			var dateDigitObj:Object = getNowDateDigit();
			this.yyyy.num1000.gotoAndStop(dateDigitObj.y1000+1);
			this.yyyy.num0100.gotoAndStop(dateDigitObj.y0100+1);
			this.yyyy.num0010.gotoAndStop(dateDigitObj.y0010+1);
			this.yyyy.num0001.gotoAndStop(dateDigitObj.y0001+1);
			this.MM.num10.gotoAndStop(dateDigitObj.M10+1);
			this.MM.num01.gotoAndStop(dateDigitObj.M01+1);
			this.dd.num10.gotoAndStop(dateDigitObj.d10+1);
			this.dd.num01.gotoAndStop(dateDigitObj.d01+1);
			this.hh.num10.gotoAndStop(dateDigitObj.h10+1);
			this.hh.num01.gotoAndStop(dateDigitObj.h01+1);
			this.mm.num10.gotoAndStop(dateDigitObj.m10+1);
			this.mm.num01.gotoAndStop(dateDigitObj.m01+1);
			this.ss.num10.gotoAndStop(dateDigitObj.s10+1);
			this.ss.num01.gotoAndStop(dateDigitObj.s01+1);
		}
		//現在時刻を調べる
		function getNowDateDigit():Object {
			
			//現在時刻の時分秒を調べる
			var now:Date = new Date();
			var yy:Number = now.getFullYear();
			var MM:Number = now.getMonth() + 1;
			var dd:Number = now.getDate();
			var hh:Number = now.getHours();
			var mm:Number = now.getMinutes();
			var ss:Number = now.getSeconds();
			
			//2桁を1桁ずつに分ける
			var dateDigitObj:Object = new Object();
			dateDigitObj.y1000 = Math.floor(yy/1000);
			dateDigitObj.y0100 = Math.floor(yy/100) - Math.floor(yy/1000) * 10;
			dateDigitObj.y0010 = Math.floor(yy/10) - dateDigitObj.y1000*100 - dateDigitObj.y0100*10;
			dateDigitObj.y0001 = yy % 10;
			dateDigitObj.M10 = Math.floor(MM/10);
			dateDigitObj.M01 = MM%10;
			dateDigitObj.d10 = Math.floor(dd/10);
			dateDigitObj.d01 = dd % 10;

			dateDigitObj.h10 = Math.floor(hh/10);
			dateDigitObj.h01 = hh%10;
			dateDigitObj.m10 = Math.floor(mm/10);
			dateDigitObj.m01 = mm%10;
			dateDigitObj.s10 = Math.floor(ss/10);
			dateDigitObj.s01 = ss % 10;
			return dateDigitObj;
		}
	}	
}