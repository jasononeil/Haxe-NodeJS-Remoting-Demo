class Client
{
	public static function main()
	{
		// Set the trace output to use firebug / console.
		haxe.Log.trace = haxe.Firebug.trace;

		trace ("Set up connection and proxy");


		//Create the remoting Html connection, and set an error handler.
		var conn = haxe.remoting.HttpAsyncConnection.urlConnect("http://localhost:8000");
		conn.setErrorHandler( function(err) trace("Error : " + err));

		//Build and instantiate the proxy class with macros.  
		//The full path to the server class is given as a String, but it is NOT compiled into the client.
		//It can be given as a class declaration, but then it is compiled into the client (not what you want)
		var apiProxy = haxe.remoting.Macros.buildAndInstantiateRemoteProxyClass("ServerAPI", conn);
		
		//You can use code completion here




		apiProxy.getTheFoo("fooId", function (foo :String) :Void {
		    trace("successfully got the foo=" + foo);
		});

		apiProxy.getTheBar("fooId", function (foo :String) :Void {
		    trace("successfully got the bar=" + foo);
		});
	}
}
