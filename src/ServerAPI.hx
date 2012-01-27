import js.Node;

// This API runs on the server, but is shared through remoting. 
// All public methods with the "@remote" metadata are shared.  Each method must have a callback as the last argument. 
// From what I can tell, the callback must be SomeClass->Void.  So it can't be 
//     String->Int->Void             function(s:String, i:Int):Void
// for example, but it could be
//     MyComplexType->Void           function(o:MyComplexType):Void

class ServerAPI
{
    public function new()
    {
    	// it needs to have new() so it can be created, but it doesn't need to do anything...
    }

    /** Add two numbers together and pass the result back to the client */
    @remote public function sumOfTwoNumbers(a:Float, b:Float, cb:Float->Void)
    {
    	// This incredibly complex calculation takes place on the server
    	var sum = a + b;

    	// and then we run the callback function, passing in the return value
        cb(sum);
    }

    /** Get information about the server NodeJS is running on.  Join it as a string and send back to the client. */
    @remote public function serverInfo(cb:Dynamic->Void):Void
    {
    	// Get some information from the NodeJS Server
    	// Package it in an anonymous object, because as far as I can tell you can only send one object to the cb function
    	var info = {
    		platform: Node.os.platform(),
    		release: Node.os.release(),
    		hostname: Node.os.hostname()
    	}

    	// Send it back to the client, calling the callback function they specified
    	cb(info);
    }

    /** Get the text of the NodeJS file this server is running on.*/
    @remote
    public function getTheServerScript(cb:String->Void) :Void
    {
    	// read the JS file that powers this server
    	var serverScript:String = Node.fs.readFileSync(Node.__filename, "utf8");

    	// and pass it to the client as a string
    	cb(serverScript);
    }

    /** Check if the client's login details are correct */
    @remote public function login(username:String, password:String, cb:Bool->Void)
    {
    	// if the username and password equal these really secure fake passwords, 
    	// then the login works, and the result is "true"
    	var result = (username == "correctUsername") && (password == "correctPassword");
    	
    	// tell the client the result of the login
    	cb(result);
    }

}