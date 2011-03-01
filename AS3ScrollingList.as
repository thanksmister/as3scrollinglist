/**
 * @author Michael Ritchie
 * @blog http://www.thanksmister.com
 * @twitter Thanksmister
 * Copyright (c) 2010
 * 
 * This is a Flash application to test the TouchList component.
 * */
package
{
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageOrientation;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.StageOrientationEvent;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import com.thanksmister.touchlist.renderers.TouchListItemRenderer;
	import com.thanksmister.touchlist.events.ListItemEvent;
	import com.thanksmister.touchlist.controls.TouchList;
	
	[SWF( width = '480', height = '800', backgroundColor = '#000000', frameRate = '24')]
	public class AS3ScrollingList extends MovieClip
	{
		private var touchList:TouchList;
		private var textOutput:TextField;
		private var stageOrientation:String = StageOrientation.DEFAULT;
		
		public function AS3ScrollingList()
		{
			// needed to scale our screen
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			if(stage) 
				init();
			else
				stage.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			stage.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			stage.addEventListener(Event.RESIZE, handleResize);
			
			// if we have autoOrients set in permissions we add listener
			if(Stage.supportsOrientationChange) {
				stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, handleOrientationChange);
			}
			
			if(Capabilities.cpuArchitecture == "ARM") {
				NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, handleActivate, false, 0, true);
				NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, handleDeactivate, false, 0, true);
			}
			
			// add our list and listener
			touchList = new TouchList(stage.stageWidth, stage.stageHeight);
			touchList.addEventListener(ListItemEvent.ITEM_SELECTED, handlelistItemSelected);
			addChild(touchList);
			
			// Fill our list with item rendreres that extend ITouchListRenderer. 
			for(var i:int = 0; i < 50; i++) {
				var item:TouchListItemRenderer = new TouchListItemRenderer();
					item.index = i;
					item.data = "This is list item " + String(i);
					item.itemHeight = 80;
			
				touchList.addListItem(item);
			}
		}
		
		/**
		 * Handle stage orientation by calling the list resize method.
		 * */
		private function handleOrientationChange(e:StageOrientationEvent):void
		{
			switch (e.afterOrientation) { 
				case StageOrientation.DEFAULT: 
				case StageOrientation.UNKNOWN: 
					//touchList.resize(stage.stageWidth, stage.stageHeight);
					break; 
				case StageOrientation.ROTATED_RIGHT: 
				case StageOrientation.ROTATED_LEFT: 
					//touchList.resize(stage.stageHeight, stage.stageWidth);
					break; 
			} 
		}
		
		private function handleResize(e:Event = null):void
		{
			touchList.resize(stage.stageWidth, stage.stageHeight);
		}
		
		private function handleActivate(event:Event):void
		{
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
		}
		
		private function handleDeactivate(event:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		/**
		 * Handle keyboard events for menu, back, and seach buttons.
		 * */
		private function handleKeyDown(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.BACK) {
				e.preventDefault();
				NativeApplication.nativeApplication.exit();
			} else if(e.keyCode == Keyboard.MENU){
				e.preventDefault();
			} else if(e.keyCode == Keyboard.SEARCH){
				e.preventDefault();
			}
		}
		
		/**
		 * Handle list item seleced.
		 * */
		private function handlelistItemSelected(e:ListItemEvent):void
		{
			trace("List item selected: " + e.renderer.index);
		}
	}
}