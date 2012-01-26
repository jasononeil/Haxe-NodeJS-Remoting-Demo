//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package haxe.remoting;

/**
 * Node uses callbacks in the form of function(error, result) as a standard
 * convention for asynchronous operations.
 */
typedef NodeCallback<A> = Dynamic -> A -> Void;

/**
 * Manages control flow in heavily asynchronous apps. Propagates NodeCallback errors and uncaught
 * exceptions up to error().
 *
 * <code>
 * var relay :NodeRelay<String>;
 * // ...
 * myLib.doAsyncOperation(relay.chain(function (result) {
 *	 if (!validateResult(result)) {
 *		 throw "Validation failed";
 *	 }
 *	 db.moarAsync(relay.nodeCallback(function (result) {
 *		 relay.success(result.name);
 *	 }));
 * }));
 * </code>
 */
class NodeRelay<T>
{
	public var onSuccess (null, default) :T -> Void;
	public var onError (null, default) :Dynamic -> Void;

	public function new (onSuccess :T -> Void)
	{
		this.onSuccess = onSuccess;
	}

	public function success (result :T)
	{
		// try {
			onSuccess(result);
		// } catch (e :Dynamic) {
		// 	error(e + haxe.Stack.toString(haxe.Stack.callStack()));
		// }
	}

	public function error (err :Dynamic)
	{
		if (onError != null) {
			onError(err);
		}
		#if debug
		trace("Err: " + Std.string(err) + haxe.Stack.toString(haxe.Stack.exceptionStack()));
		#end
	}

	public function chain<A> (handler :A -> Void) :NodeRelay<A>
	{
		var relay = new NodeRelay(handler);
		relay.onError = this.onError;
		return relay;
	}

	/**
	 * Many libraries use Node-style callbacks, this creates a NodeCallback compatible with them
	 * that works with this relay's error handling.
	 */
	public function nodeCallback<A> (handler :A -> Void) :NodeCallback<A>
	{
		return function (err, x :A) {
			if (err != null) {
				error(err);
			} else {
				try {
					handler(x);
				} catch (e :Dynamic) {
					error(e);
				}
			}
		};
	}

	public function nodeCallback0 () :NodeCallback<T>
	{
		return nodeCallback(onSuccess);
	}
}
