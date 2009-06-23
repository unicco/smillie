package {
	import caurina.transitions.*;
	import caurina.transitions.properties.*;
	import fl.transitions.Photo;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	import flash.events.*;
	import flash.display.*;
	import flash.net.*;
	import flash.system.System;
	
	/**
	* ...
	* @author Kansai Takako
	*/
	public class Main extends Sprite {
		private static var MAX_COUNT:Number = 20;
		private var _ldr:URLLoader;
		private var _xml:XML;
		private var _dtPhoto:DisplayObject;
		private var _prevDtPhoto:DisplayObject;
		private var _liquidBG:LiquidBG;
		private var _dgClock:DigitalClock;
		private var _phCount:PhotoCount;
		private var _ldPhotoCount:Number;
		private var _qr:QrCode;
		private var _explBox:ExplBox;
		private var _phScreen:PhotoScreen;
		private var _phLength:Number; //xml に含まれる写真の数
		private var _phSumLength:Number; //全体の写真の数
		private var _phLoadCount:Number; //ロードした写真の数
		private var _phDetailCount:Number; //ロードした写真の数
		private static var _myObj:Main;
		private var paramObj:Object; //HTML から受け取ったパラメータ
		private var partyKey:String;
		private var domain:String = "http://localhost:3001/";
		private var clockTimer:Timer;
		private var phShowTimer:Timer;
		private var phClearTimer:Timer;
		private var phDetailTimer:Timer;
		private var phRemoveTimer:Timer;
		private var prevDtX:Number;
		private var prevDtY:Number;
		private var prevDtR:Number;
		private var orgDtX:Number;
		private var orgDtY:Number;
		
		public function Main() {
			init(); //初期化
			//setXmlTimer(); //XML を取得するタイマー
			getXML(); //初回の XML 取得
		}

		private function init() {
			_myObj = this;
			stage.scaleMode = "noScale";
			stage.align = "TOP_LEFT";
			
			//Tweener 用初期化
			ColorShortcuts.init();
			FilterShortcuts.init();
			DisplayShortcuts.init();
			CurveModifiers.init();
			
			//背景の初期化
			_liquidBG = new LiquidBG();
			this.addChild(_liquidBG);
			_liquidBG.init(); //addChild してからじゃないと this.stage で stage の情報が取れない
			
			//写真ステージの初期化
			_phScreen = new PhotoScreen();
			this.addChild(_phScreen);
			_phScreen.init();
			
			//時計の初期化
			_dgClock = new DigitalClock();
			this.addChild(_dgClock);
			
			//説明フィールドの初期化
			_explBox = new ExplBox();
			this.addChild(_explBox);
			
			//QR コードの初期化
			_qr = new QrCode();
			_explBox.addChild(_qr);
			
			//写真枚数の初期化
			_phCount = new PhotoCount();
			this.addChild(_phCount);
			_phCount.init();
		}
		//XML の取得
		private function getXML() {
			removePhoto();
			//XML の読み込み
			_ldr = new URLLoader();
			_ldr.addEventListener(Event.COMPLETE, ldCompHandler);
			_ldr.addEventListener(IOErrorEvent.IO_ERROR, function(evt:Event) { trace("load err."); } );
			
			paramObj = LoaderInfo(this.root.loaderInfo).parameters;
			
			//party_key を代入
			if (paramObj["party_key"]) {
				partyKey = String(paramObj["party_key"]);
				domain = "/"
			} else {
				//　テスト用
				partyKey = "unicco"
			};
			_ldr.load(new URLRequest(domain + partyKey + "/photos.xml"));
			trace(domain + partyKey + "/photos.xml");
		}
		private function removePhoto() {
			var phCount:Number = _phScreen.numChildren;
			if (phCount > 0) {
				for (var i:Number = 0; i < phCount; i++) {
					var p:Photo = Photo(_phScreen.getChildAt(0));
					var ldr:Loader = Loader(p.bildeHolder.getChildAt(0));
					ldr.unload();
					_phScreen.removeChildAt(0);
				}
			}
		}
		private function ldCompHandler(evt:Event) {
			_ldr.removeEventListener(Event.COMPLETE, ldCompHandler);
			_ldr.removeEventListener(IOErrorEvent.IO_ERROR, function(evt:Event) { trace("load err."); } );
			
			_xml = new XML(_ldr.data);
			_phSumLength = _xml.photo.length();
			
			trace("[memory]" + System.totalMemory);
			
			//投稿用アドレスの読み込み
			_explBox.init(_xml);
			
			//QR コードの読み込み
			_qr.init(_xml);
			
			_xml = compressXML(_xml);
			loadContents();
		}
		private function compressXML(xml:XML) {
			var x:XML = <photos />;
			var d:XML = new XML;
			var now:Date = new Date();
			var count:Number = 0;
			var last:Number = -1;
			
			if (xml.photo.length() <= MAX_COUNT) { return xml; }
			for (var i:Number = 0; i < xml.photo.length(); i++) {
				if (Date(xml.photo[i].@date) > now) {
					d = XML("<photo link=\"" + xml.photo[i].@link + "\" date=\"" + xml.photo[i].@date + "\" id=\"" + xml.photo[i].@id + "\" />");
					x.appendChild(d);
					count++;
					last = i;
				}
			}
			if (count >= MAX_COUNT) { return x; }
			var span:Number = Math.floor((xml.photo.length() - count) / (MAX_COUNT - count));
			var r:Number = Math.floor((Math.random()) * span);
			for (i = last + 1; i < xml.photo.length(); i++) {
				if (i % span == r) {
					d = XML("<photo link=\"" + xml.photo[i].@link + "\" date=\"" + xml.photo[i].@date + "\" id=\"" + xml.photo[i].@id + "\" />");
					x.appendChild(d);
				}
			}
			return x;
		}
		// ステージに配置
		private function loadContents() {
			_phLength = _xml.photo.length();
			//写真の読み込み
			_phCount.updateCount(_phSumLength);
			_phLoadCount = 0;
			phShowTimer = new Timer(300, _phLength);
			phShowTimer.addEventListener(TimerEvent.TIMER, onShowPhoto);
			phShowTimer.start();
		}
		private function onDetailPhoto(event:TimerEvent):void {
			if (_phDetailCount != _phLength){
				_dtPhoto = _phScreen.getChildAt(0);
				
				orgDtX = this.stage.stageWidth - 280;
				orgDtY = this.stage.stageHeight / 2 - 40;
				
				//順番の入れ替え
				_phScreen.setChildIndex(_dtPhoto, _phScreen.numChildren - 1);
				Tweener.addTween(_dtPhoto, { x:orgDtX , y:orgDtY, scaleX:0.95, scaleY:0.95, rotation:0, time:1, delay:0 } );
				
				if (_phDetailCount > 0) {
					_prevDtPhoto = _phScreen.getChildAt(_phScreen.numChildren - 2);
					Tweener.addTween(_prevDtPhoto, { x:prevDtX , y:prevDtY, scaleX:0.3, scaleY:0.3, rotation:prevDtR, time:1, delay:0 } );
				}
				
				prevDtX = _dtPhoto.x;
				prevDtY = _dtPhoto.y;
				prevDtR = _dtPhoto.rotation;
				_phDetailCount++;
			} else {
				Tweener.addTween(_dtPhoto, { x:prevDtX , y:prevDtY, scaleX:0.3, scaleY:0.3, rotation:prevDtR, time:1, delay:0 } );
			}
		}
		
				private function onCompDetailPhoto(event:TimerEvent):void {
			_ldPhotoCount = 0;
			phClearTimer = new Timer(300, _phScreen.numChildren);
			phClearTimer.addEventListener(TimerEvent.TIMER, onClearPhoto);
			phClearTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(evt:Event) {
				removeEventListener(TimerEvent.TIMER, onClearPhoto);
				//removeEventListener(TimerEvent.TIMER_COMPLETE, this);
				phClearTimer.stop();
				//evt.target.stop();
				getXML();
				}
			);
			phClearTimer.start();
			
			phDetailTimer.removeEventListener(TimerEvent.TIMER,onCompDetailPhoto);
			phDetailTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onDetailPhoto);
			phDetailTimer.stop();
				}
		
		private function onClearPhoto(event:TimerEvent):void {
			if (_phScreen.numChildren > 0) {
				Tweener.addTween(_phScreen.getChildAt(_ldPhotoCount), {
					x: Math.random() * this.stage.stageWidth, y:-150, time:1, delay:0
				} );
				_ldPhotoCount++;
			}
		}
		
		private function onShowPhoto(event:TimerEvent):void {
			var photo:Photo = new Photo();
			_phScreen.addChild(photo);
			photo.x = Math.random() * this.stage.stageWidth;
			photo.y = this.stage.stageHeight + photo.height;
			photo.init(_xml.photo[_phLoadCount], _xml.photo.length(), _phLoadCount);
			_phLoadCount++;
		}
		public function onCompShowPhoto() {
			phShowTimer.removeEventListener(TimerEvent.TIMER, onShowPhoto);
			phShowTimer.stop();
			
			_phDetailCount = 0;
			phDetailTimer = new Timer(5000, _phScreen.numChildren + 1);
			phDetailTimer.addEventListener(TimerEvent.TIMER, onDetailPhoto);
			phDetailTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onCompDetailPhoto);
			phDetailTimer.start();
				}
		public static function getInstance():Main {
			return _myObj;
		}
	}
}