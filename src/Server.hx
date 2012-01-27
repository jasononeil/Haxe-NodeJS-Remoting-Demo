import js.Node; 
import js.node.Connect;
import js.node.JsHelper;

import haxe.remoting.NodeJsHtmlConnection;

class Server 
{
	/** Main function to be called when the server is initialised */
	public static function main()
	{
		// Set up a have remoting context, fire up a ServerAPI object, and add it to the context
		var context = new haxe.remoting.Context();
		var serverApi = new ServerAPI();
		context.addObject(haxe.remoting.Macros.getRemotingId(ServerAPI), serverApi);

		// Set up a NodeJsHtmlConnection - this knows how to deal with incoming remoting requests
		var remotingHandler = new NodeJsHtmlConnection(context);

		// remotingMiddleWare - this might need an explanation.
		// In the NodeJS ecosystem, Connect is a library that allows you to plug in a whole stack of "middleware"
		// that is run on each request.  Each middleware has the chance to do something with the 
		// request - set it, add to it, modify it, log it, gzip it, provide an error message etc.
		// Here we create a new middleWare that is a function that checks if it's a remoting request,
		// and if it is, it does the request, if it's not, it passes it on to the next middleware.
		var remotingMiddleWare = function (req :NodeHttpServerReq, res :NodeHttpServerResp, next :Void->MiddleWare) :Void 
		{
			// use our remotingHandler (which is a NodeJsHtmlConnection) to handle the request
			var result = remotingHandler.handleRequest(req, res);

			// if the handler returned a result of "false", this means it was not a remoting request,
			// it was a normal request.  So we call "next()" to pass it on to the next middleware, 
			// which will know what to do
			if (result == false) 
			{
				next();
			}
		}

		// Now we use connect.createServer(), which is an extension of http.createServer() from haxenode.org's example.
		// The advantage here is that connect() includes all the middleware support we need to get remoting to work.
		var connect:Connect = Node.require('connect');
		var server = connect.createServer(
			// Middleware1: errorhandler, Set to a pre-built one from the "connect" library
			connect.errorHandler({showStack:true, showMessage:true, dumpExceptions:true}), 

			
			
			// Middleware2: our remoting middleware
			remotingMiddleWare, 

			// Middleware3: if it's not a remoting call, look for a static file.  Use connect.static()
			// There's an error in the nodejs_externs typedef where it looks for connect.Static not connect.static.
			// I might ask the mailing list if there's a clean way to make "Static" a function that points to "static"
			//connect.Static(Node.__dirname + "/public/", {redirect:true})
			Reflect.field(connect, "static")(Node.__dirname + "/static/", {redirect:true})
		);

		// tell the server to listen to this port on this IP address
		server.listen(8000, "127.0.0.1");
		trace ("listening on port 8000");
	}
}