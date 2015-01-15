package js.npm.express;

extern class Compression
implements npm.Package.Require<"compression", "^1.10.1"> #if !haxe3,#end
implements Middleware.IMiddleware<Request, Response>
{
	public function new(?options : {}) : Void;
}
