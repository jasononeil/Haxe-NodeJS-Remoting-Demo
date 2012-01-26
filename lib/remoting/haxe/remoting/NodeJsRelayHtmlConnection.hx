/*******************************************************************************
 * Hydrax: haXe port of the PushButton Engine
 * Copyright (C) 2010 Dion Amago
 * For more information see http://github.com/dionjwa/Hydrax
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package haxe.remoting;

#if !js
#error
#end

import haxe.remoting.Context;

import js.Node;

/**
  * Haxe HTTP remoting connection for node.js
  * Expects that the last argument in server-side remoting calls is a NodeRelay<T> 
  */
class NodeJsRelayHtmlConnection
{
	var _context :Context;
	
	public function new (ctx :Context)
	{
		_context = ctx;
	}
	
	public function connect (ctx :Context) :Void
	{
		if (_context != null) throw "Context is already set";
		_context = ctx;
	}
	
	public function handleRequest (req :NodeHttpServerReq, res :NodeHttpServerResp) :Bool 
	{
		if (req.method != "POST" || req.headers[untyped "x-haxe-remoting"] != "1") {
			return false;
		}
		
		//Get the POST data
		req.setEncoding("utf8");
		var content = "";
		
		req.addListener("data", function(chunk) {
			content += chunk;
		});

		var context = _context;
		req.addListener("end", function() {
			req.removeAllListeners("data");
			req.removeAllListeners("end");
			
			var relay = new NodeRelay(function (data :Dynamic) {
				res.end("hxr" + Serializer.run(data));
			});
			
			relay.onError = function (err :Dynamic) {
				var message = (err.message != null) ? err.message : err;
				var stack = err.stack;

				Node.util.log("Remoting exception: " +
					(err.stack != null ? err.stack : message));

				var s = new haxe.Serializer();
				s.serializeException(message);
				res.end("hxr" + s.toString());
			};
			
			res.setHeader("Content-Type", "text/plain");
			res.setHeader("x-haxe-remoting", "1");
			res.writeHead(200);
			
			try {
				var params = querystring.parse(content);
				var requestData = params.__x;
				var u = new haxe.Unserializer(requestData);
				var path = u.unserialize();
				var args :Array<Dynamic> = u.unserialize();
				args.push(relay);
				_context.call(path,args);
			} catch (e :Dynamic) {
				relay.error(e);
			}
		});
		
		return true;
	}
	
	private static var querystring = Node.require("querystring");
}
