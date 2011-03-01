/**
 * @author Michael Ritchie
 * @blog http://www.thanksmister.com
 * @twitter Thanksmister
 * Copyright (c) 2011
 * 
 * ITouchListItemRenderer must be implemented in any item renderer you want to use for the list.
 * */
package com.thanksmister.touchlist.renderers
{
	public interface ITouchListItemRenderer
	{
		function set data(value:Object):void;
		function get data():Object;
		function set index(value:Number):void;
		function get index():Number;
		function set itemWidth(value:Number):void;
		function get itemWidth():Number;
		function set itemHeight(value:Number):void;
		function get itemHeight():Number;
		function selectItem():void;
		function unselectItem():void;
	}
}