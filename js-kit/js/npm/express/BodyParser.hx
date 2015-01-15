package js.npm.express;

import js.node.Buffer;

typedef UrlencodedOptions = {
	extended : Bool,
	?inflate : Bool,
	?limit : Int,
	?parameterLimit : Int,
	?type : String,
	?verify : Request -> Response -> Buffer -> String -> Void
}

extern class BodyParser
implements npm.Package.Require<"body-parser", "^1.10.1"> #if !haxe3,#end
implements Middleware.IMiddleware<Request, Response>
{
	public static function json(?options : {}) : BodyParser;
	public static function raw(?options : {}) : BodyParser;
	public static function text(?options : {}) : BodyParser;
	public static function urlencoded(?options : UrlencodedOptions) : BodyParser;

	public inline static function body(req : Request) : Dynamic {
		return untyped req.body;
	}
}
