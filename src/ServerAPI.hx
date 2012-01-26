/** This API runs on the server, but is shared through remoting. */
class ServerAPI
{
    public function new()
    {
    	
    }

    @remote
    public function getTheFoo(fooId :String, cb :String->Void) :Void
    {
        cb("someFoo");
    }

    @remote public function getTheBar(fooId :String, cb :String->Void) :Void
    {
        cb("someBar");
    }

}