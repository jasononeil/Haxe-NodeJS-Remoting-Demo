import js.Node; 
import js.node.Connect;
import js.node.JsHelper;

import haxe.remoting.NodeJsHtmlConnection;

class Server 
{
	public static function main()
	{
		var context = new haxe.remoting.Context();

		var remotingmanager = new ServerAPI();
		context.addObject(haxe.remoting.Macros.getRemotingId(ServerAPI), remotingmanager);

		var remotingHandler = new NodeJsHtmlConnection(context);

		var remotingMiddleWare = function (req :NodeHttpServerReq, res :NodeHttpServerResp, next :Void->MiddleWare) :Void 
		{
			if (!remotingHandler.handleRequest(req, res)) 
			{
				trace ("handleRequest was negative - pass on to next()");
				next();
			}
			else
			{
				trace ("handleRequest worked");
			}
		}

		var connect :Connect = Node.require('connect');

		connect.createServer(
			connect.errorHandler({showStack:true, showMessage:true, dumpExceptions:true}), 
			remotingMiddleWare, 
			function (req :NodeHttpServerReq, res :NodeHttpServerResp, next :Void->MiddleWare):Void 
			{
				if (req.url.length < 2) 
				{
					res.write(html, "utf8");
					res.writeHead(200);
					res.end();
				} 
				else 
				{
					next();
				}
			}, 
			//Issues with the 'static' keyword
			untyped __js__("connect.static(__dirname + '/static/')")
		).listen(8000, "127.0.0.1");

		trace ("listening on port 8000");
	}

	public static var html = '<html>
<head>
	<title>Client / Server Remoting with haXe JS, and Node JS (also haXe).</title>
	<script type="text/javascript" src="client.js"></script>
</head>
<body>
	<h1>Test</h1>
</body>
</html>';
}