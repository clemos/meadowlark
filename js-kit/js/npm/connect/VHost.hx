package js.npm.connect;

import js.node.http.ClientRequest;

extern class VHostHost implements ArrayAccess<String>
{
	public var host : String;
	public var hostname : String;
	public var length : Int;
}

extern class VHost
implements npm.Package.Require<"vhost", "~3.0.0">
implements js.npm.connect.Middleware
{
	@:overload(function(hostname : EReg, app : Dynamic) : Void {})
	public function new(hostname : String, app : Dynamic) : Void;

	public inline static function vhost(req : ClientRequest) : VHostHost {
		return untyped req.vhost;
	}	
}
