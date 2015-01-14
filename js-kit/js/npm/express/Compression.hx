package js.npm.express;

extern class Compression
implements npm.Package.Require<"compression", "~1.10.1">
implements Middleware.IMiddleware<Request, Response>
{
	public function new(?options : {}) : Void;
}
