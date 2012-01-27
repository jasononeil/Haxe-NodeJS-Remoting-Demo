package org.transition9.util;

import org.transition9.util.svg.SvgData;

import js.Dom;

/**
  * Js specific debugging/testing utilities
  */
class JsDebugUtil
{
	public static function insertIntoDebugDiv (element :HtmlDom) :Void
	{
		var debugElement = js.Lib.document.getElementById("debug");
		org.transition9.util.Assert.isNotNull(debugElement, ' debugElement is null');
		var div :HtmlDom = cast js.Lib.document.createElement("div");
		debugElement.appendChild(div);
		div.appendChild(element);
	}
	
	public static function insertSvgIntoDebugDiv (svg :SvgData) :Void
	{
		var svgdiv :js.Dom.HtmlDom = cast js.Lib.document.createElement("div");
		svgdiv.innerHTML = svg.data;
		insertIntoDebugDiv(svgdiv);
	}
}
