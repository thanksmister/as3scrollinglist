/**
 * @author Michael Ritchie
 * @blog http://www.thanksmister.com
 * @twitter Thanksmister
 * Copyright (c) 2010
 * 
 * TouchList is an ActionScript 3 scrolling list for Android mobile phones. I used and modified some code
 * within the component from other Flex/Flash examples for scrolling lists by the following people or location:
 * 
 * Dan Florio ( polyGeek )
 * polygeek.com/2846_flex_adding-physics-to-your-gestures
 * 
 * James Ward
 * www.jamesward.com/2010/02/19/flex-4-list-scrolling-on-android-with-flash-player-10-1/
 * 
 * FlepStudio
 * www.flepstudio.org/forum/flepstudio-utilities/4973-tipper-vertical-scroller-iphone-effect.html
 * 
 * You may use this code for your personal or professional projects, just be sure to give credit where credit is due.
 * */
package com.thanksmister.touchlist.controls 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import com.thanksmister.touchlist.renderers.ITouchListItemRenderer;
	import com.thanksmister.touchlist.events.ListItemEvent;
	

	public class TouchList extends Sprite
	{
		//------- List --------

		private var listHitArea:Shape;
		private var list:Sprite;
		private var listHeight:Number = 100;
		private var listWidth:Number = 100;
		private var scrollListHeight:Number;
		private var scrollAreaHeight:Number;
		private var listTimer:Timer; // timer for all events
		
		//------ Scrolling ---------------
		
		private var scrollBar:MovieClip;
		private var lastY:Number = 0; // last touch position
		private var firstY:Number = 0; // first touch position
		private var listY:Number = 0; // initial list position on touch 
		private var diffY:Number = 0;;
		private var inertiaY:Number = 0;
		private var minY:Number = 0;
		private var maxY:Number = 0;
		private var totalY:Number;
		private var scrollRatio:Number = 40; // how many pixels constitutes a touch
		
		//------- Touch Events --------
		
		private var isTouching:Boolean = false;
		private var tapDelayTime:Number = 0;
		private var maxTapDelayTime:Number = 5; // change this to increase or descrease tap sensitivity
		private var tapItem:ITouchListItemRenderer;
		private var tapEnabled:Boolean = false;

		// ------ Constructor --------
		
		public function TouchList(w:Number, h:Number)
		{
			listWidth = w; 
			listHeight = h;
			
			scrollAreaHeight = listHeight;

			addEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(Event.REMOVED, destroy);
		}
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown );
		
			listTimer = new Timer( 33 );
			listTimer.addEventListener( TimerEvent.TIMER, onListTimer);
			listTimer.start();
			
			scrollListHeight = 0;
			
			creatList();
			createScrollBar();
		}
		
		/**
		 * Create an empty list an the list hit area, which is also its mask.
		 * */
		private function creatList():void
		{
			if(!listHitArea){
				listHitArea = new Shape();
				addChild(listHitArea);
			}
			
			listHitArea.graphics.clear();
			listHitArea.graphics.beginFill(0x000000, 1);
			listHitArea.graphics.drawRect(0, 0, listWidth, listHeight)
			listHitArea.graphics.endFill();
			
			if(!list){
				list = new Sprite();
				addChild(list);
			}
			
			list.graphics.clear();
			list.graphics.beginFill(0x000000, 1);
			list.graphics.drawRect(0, 0, listWidth, listHeight)
			list.graphics.endFill();
			list.mask = listHitArea;
		}
		
		/**
		 * Create our scroll bar based on the height of the scrollable list.
		 * */
		private function createScrollBar():void
		{
			if(!scrollBar) {
				scrollBar = new MovieClip();
				addChild(scrollBar);
			}
			
			scrollBar.x = listWidth - 5;
			scrollBar.graphics.clear();
			
			if(scrollAreaHeight < scrollListHeight) {
				scrollBar.graphics.beginFill(0x505050, .8);
				scrollBar.graphics.lineStyle(1, 0x5C5C5C, .8);
				scrollBar.graphics.drawRoundRect(0, 0, 4, (scrollAreaHeight/scrollListHeight*scrollAreaHeight), 6, 6);
				scrollBar.graphics.endFill();
				scrollBar.alpha = 0;
			}
		}
		
		// ------ public methods --------
		
		/**
		 * Redraw component usually as a result of orientation change.
		 * */
		public function resize(w:Number, h:Number):void
		{
			listWidth = w; 
			listHeight = h;
			
			scrollAreaHeight = listHeight;
			
			creatList(); // redraw list
			createScrollBar(); // resize scrollbar
			
			// resize each list item
			var children:Number = list.numChildren;
			for (var i:int = 0; i < children; i++) {
				var item:DisplayObject = list.getChildAt(i);
				ITouchListItemRenderer(item).itemWidth = listWidth;
			}
		}
		
		/**
		 * Add single item renderer to the list. Renderes added to the list
		 * must implement ITouchListItemRenderer. 
		 * */
		public function addListItem(item:ITouchListItemRenderer):void
		{
			var listItem:DisplayObject = item as DisplayObject;
				listItem.y = scrollListHeight;
				listItem.addEventListener(ListItemEvent.ITEM_SELECTED, handleItemSelected);
				listItem.addEventListener(ListItemEvent.ITEM_PRESS, handleItemPress);
				
			ITouchListItemRenderer(listItem).itemWidth = listWidth;
				
			scrollListHeight = scrollListHeight + listItem.height;
			
			list.addChild(listItem);
			
			createScrollBar(); // update scrollbar
		}
		
		/**
		 * Remove item from list and listeners.
		 * */
		public function removeListItem(index:Number):void
		{
			var item:DisplayObject = list.removeChildAt(index);
				item.removeEventListener(ListItemEvent.ITEM_SELECTED, handleItemSelected);
				item.removeEventListener(ListItemEvent.ITEM_PRESS, handleItemPress);
		}
		
		/**
		 * Clear the list of all item renderers.
		 * */
		public function removeListItems():void
		{
			tapDelayTime = 0;

			listTimer.stop();
			isTouching = false;
			scrollAreaHeight = 0;
			scrollListHeight = 0;
			
			while(list.numChildren > 0) {
				var item:DisplayObject = list.removeChildAt(0);
				item.removeEventListener(ListItemEvent.ITEM_SELECTED, handleItemSelected);
				item.removeEventListener(ListItemEvent.ITEM_PRESS, handleItemPress);
			}
		}
		
		// ------ private methods -------
		
		/**
		 * Detects frist mouse or touch down position.
		 * */
		protected function onMouseDown( e:Event ):void 
		{
			addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);

			inertiaY = 0;
			firstY = mouseY;
			listY = list.y;
			minY = Math.min(-list.y, -scrollListHeight + listHeight - list.y);
			maxY = -list.y;
		}
		
		/**
		 * List moves with mouse or finger when mouse down or touch activated. 
		 * If we move the list moves more than the scroll ratio then we 
		 * clear the selected list item. 
		 * */
		protected function onMouseMove( e:MouseEvent ):void 
		{
			totalY = mouseY - firstY;
	
			if(Math.abs(totalY) > scrollRatio) isTouching = true;

			if(isTouching) {
				
				diffY = mouseY - lastY;	
				lastY = mouseY;

				if(totalY < minY)
					totalY = minY - Math.sqrt(minY - totalY);
			
				if(totalY > maxY)
					totalY = maxY + Math.sqrt(totalY - maxY);
			
				list.y = listY + totalY;
				
				onTapDisabled();
			}
		}
		
		/**
		 * Handles mouse up and begins animation. This also deslects
		 * any currently selected list items. 
		 * */
		protected function onMouseUp( e:MouseEvent ):void 
		{
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown );
			removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				
			if(isTouching) {
				isTouching = false;
				inertiaY = diffY;
			}
		
			onTapDisabled();
		}
		
		/**
		 * Timer event handler.  This is always running keeping track
		 * of the mouse movements and updating any scrolling or
		 * detecting any tap events.
		 * 
		 * Mouse x,y coords come through as negative integers when this out-of-window tracking happens. 
		 * The numbers usually appear as -107374182, -107374182. To avoid having this problem we can 
		 * test for the mouse maximum coordinates.
		 * */
		private function onListTimer(e:Event):void
		{
			// test for touch or tap event
			if(tapEnabled) {
				onTapDelay();
			}
			
			// scroll the list on mouse up
			if(!isTouching) {
				
				if(list.y > 0) {
					inertiaY = 0;
					list.y *= 0.3;
					
					if(list.y < 1) {
						list.y = 0;
					}
				} else if(scrollListHeight >= listHeight && list.y < listHeight - scrollListHeight) {
					inertiaY = 0;

					var diff:Number = (listHeight - scrollListHeight) - list.y;
					
					if(diff > 1)
						diff *= 0.1;

					list.y += diff;
				} else if(scrollListHeight < listHeight && list.y < 0) {
					inertiaY = 0;
					list.y *= 0.8;
					
					if(list.y > -1) {
						list.y = 0;
					}
				}
				
				if( Math.abs(inertiaY) > 1) {
					list.y += inertiaY;
					inertiaY *= 0.9;
				} else {
					inertiaY = 0;
				}
			
				if(inertiaY != 0) {
					if(scrollBar.alpha < 1 )
						scrollBar.alpha = Math.min(1, scrollBar.alpha + 0.1);
					
					scrollBar.y = listHeight * Math.min( 1, (-list.y/scrollListHeight) );
				} else {
					if(scrollBar.alpha > 0 )
						scrollBar.alpha = Math.max(0, scrollBar.alpha - 0.1);
				}
		
			} else {
				if(scrollBar.alpha < 1)
					scrollBar.alpha = Math.min(1, scrollBar.alpha + 0.1);
				
				scrollBar.y = listHeight * Math.min(1, (-list.y/scrollListHeight) );
			}
		}
		
		/**
		 * The ability to tab is disabled if the list scrolls.
		 * */
		protected function onTapDisabled():void
		{
			if(tapItem){
				tapItem.unselectItem();
				tapEnabled = false;
				tapDelayTime = 0;
			}
		}
		
		/**
		 * We set up a tap delay timer that only selectes a list
		 * item if the tap occurs for a set amount of time.
		 * */
		protected function onTapDelay():void
		{
			tapDelayTime++;
			
			if(tapDelayTime > maxTapDelayTime ) {
				tapItem.selectItem();
				tapDelayTime = 0;
				tapEnabled = false;
			}
		}
		
		/**
		 * On item press we clear any previously selected item. We only
		 * allow an item to be pressed if the list is not scrolling.
		 * */
		protected function handleItemPress(e:ListItemEvent):void
		{
			if(tapItem) tapItem.unselectItem();
			
			e.stopPropagation();
			tapItem = e.renderer;
			
			if(scrollBar.alpha == 0) {
				tapDelayTime = 0;
				tapEnabled = true;
			}
		}
		
		/**
		 * Item selection event fired from a item press.  This event does
		 * not fire if list is scrolling or scrolled after press.
		 * */
		protected function handleItemSelected(e:ListItemEvent):void
		{
			e.stopPropagation();
			tapItem = e.renderer;
			
			if(scrollBar.alpha == 0) {
				tapDelayTime = 0;
				tapEnabled = false;
				tapItem.unselectItem();
				this.dispatchEvent(new ListItemEvent(ListItemEvent.ITEM_SELECTED, e.renderer) );
			}
		}
		
		/**
		 * Destroy, destroy, must destroy.
		 * */
		protected function destroy(e:Event):void
		{
			removeEventListener(Event.REMOVED, destroy);
			removeListItems();
			tapDelayTime = 0;
			tapEnabled = false;
			listTimer = null;
			removeChild(scrollBar);
			removeChild(list);
			removeChild(listHitArea);
		}
	}
}