package js.npm.express;

extern class Cors
implements npm.Package.Require<"cors", "^2.5.2">
implements Middleware.IMiddleware<Request, Response>
{
	public function new(?options : {}) : Void;
}
