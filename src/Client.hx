class Client
{
	public static function main()
	{
		// Set the trace output to use firebug / console.
		haxe.Log.trace = haxe.Firebug.trace;

		//Create the remoting Html connection, and set an error handler.
		var conn = haxe.remoting.HttpAsyncConnection.urlConnect("http://localhost:8000");
		conn.setErrorHandler( function(err) trace("Error : " + err));

		//Build and instantiate the proxy class with macros.  
		//The full path to the server class is given as a String, but it is NOT compiled into the client.
		//It can be given as a class declaration, but then it is compiled into the client (not what you want)
		var apiProxy = haxe.remoting.Macros.buildAndInstantiateRemoteProxyClass("ServerAPI", conn);
		
		//You can use code completion from this point on...

		// a really simple example - call ServerAPI.sumOfTwoNumbers() to add these two
		// numbers together, and print the result
		apiProxy.sumOfTwoNumbers(3, 6, function (result):Void {
		    trace("The sum of our two numbers is: " + result);
		});

		// call the "ServerAPI.serverInfo()" function, and when it returns print the info
		apiProxy.serverInfo(function (info) {
			var hostname = info.hostname;
			var platform = info.platform;
			var release = info.release;

			var info = Std.format("$hostname is running $platform:$release");
			trace ("Server Info: " + info);
		});

		// call "ServerAPI.getTheServerScript()" and get the entire script,
		// then count the number of lines and print it.
		apiProxy.getTheServerScript(function (script:String) :Void {
			var numberOfLines = script.split('\n').length;
			trace("Number of lines in our serverside JS: " + numberOfLines);
		});

		// A more real world example - ask the server if the login is correct,
		// and run a function that processes the result, true or false
		apiProxy.login("correctUsername", "wrongPassword", processLoginResult);
		apiProxy.login("correctUsername", "correctPassword", processLoginResult);

		
	}

	public static function processLoginResult(didLoginWork:Bool)
	{
		if (didLoginWork == true)
		{
			trace ("This login was successful");
		}
		else
		{
			trace ("This login failed");
		}
	}
}
