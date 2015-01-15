package js.npm.express;

import js.node.stream.Writable;

typedef MorganOptions = {
	?immediate : Bool,
	?skip : Request -> Response -> Bool,
	?stream : IWritable,
}

@:enum abstract MorganFormat(String) from String to String {
	var combined = "combined";
	var common = "common";
	var dev = "dev";
	var short = "short";
	var tiny = "tiny";
}

extern class Morgan
implements npm.Package.Require<"morgan", "^1.5.1">
implements Middleware.IMiddleware<Request, Response>
{
	public function new(format : MorganFormat, ?options : MorganOptions) : Void;
	public static function token(type : String, callback : Request -> Response -> String) : Void;
}
