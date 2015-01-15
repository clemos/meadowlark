package js.npm.express;

extern class Cors
implements npm.Package.Require<"cors", "^2.5.2"> #if !haxe3,#end
implements Middleware.IMiddleware<Request, Response>
{
	public function new(?options : {}) : Void;
}
