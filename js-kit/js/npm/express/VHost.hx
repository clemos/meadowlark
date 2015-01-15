package js.npm.express;

extern class VHostHost implements ArrayAccess<String>
{
	public var host : String;
	public var hostname : String;
	public var length : Int;
}

extern class VHost
implements npm.Package.Require<"vhost", "^3.0.0"> #if !haxe3,#end
implements Middleware.IMiddleware<Request, Response>
{
	@:overload(function(hostname : EReg, app : Dynamic) : Void {})
	public function new(hostname : String, app : Dynamic) : Void;

	public inline static function vhost(req : Request) : VHostHost {
		return untyped req.vhost;
	}	
}
