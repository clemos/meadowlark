
// TODO: Classes needs to be moved into their own package so they don't pollute js.npm.
package js.npm;

typedef MessageCallback = Message -> Dynamic -> Void;

extern class Message
{
	public function reply(?json : Dynamic) : Void;
	public function next() : Void;

	public var data : Dynamic;
}

extern class Listener
{
	@:overload(function(event : String, middleware : MessageCallback, callback : MessageCallback) : Void {})
	public function on(event : String, callback : MessageCallback) : Void;
}

extern class Speaker
{
	public function request(event : String, ?data : Dynamic, ?callback : Dynamic -> Void) : Void;	
	public function shout(event : String, ?data : Dynamic) : Void;	
	public function send(event : String, ?data : Dynamic) : Void;	
}

extern class Messenger
implements npm.Package.Require<"messenger", "^0.0.9">
{
	@:overload(function(createListener : String) : Listener {})	
	public static function createListener(port : Int) : Listener;

	@:overload(function(createSpeaker : String) : Speaker {})	
	public static function createSpeaker(port : Int) : Speaker;
}
