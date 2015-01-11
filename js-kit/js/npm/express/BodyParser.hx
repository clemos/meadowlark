package js.npm.express;

import js.node.Buffer;
import js.node.http.ClientRequest;
import js.node.http.ServerResponse;

typedef UrlencodedOptions = {
	extended : Bool,
	?inflate : Bool,
	?limit : Int,
	?parameterLimit : Int,
	?type : String,
	?verify : ClientRequest -> ServerResponse -> Buffer -> String -> Void
}

extern class BodyParser
implements npm.Package.Require<"body-parser", "~1.10.1">
implements js.npm.connect.Middleware
{
	public static function json(?options : {}) : BodyParser;
	public static function raw(?options : {}) : BodyParser;
	public static function text(?options : {}) : BodyParser;
	public static function urlencoded(?options : UrlencodedOptions) : BodyParser;

	public inline static function body(req : ClientRequest) : Dynamic {
		return untyped req.body;
	}
}
