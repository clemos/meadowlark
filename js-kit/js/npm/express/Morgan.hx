package js.npm.express;

import js.node.http.ClientRequest;
import js.node.http.ServerResponse;
import js.node.stream.Writable;

typedef MorganOptions = {
	?immediate : Bool,
	?skip : ClientRequest -> ServerResponse -> Bool,
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
implements npm.Package.Require<"morgan", "~1.5.1">
implements js.npm.connect.Middleware
{
	public function new(format : MorganFormat, ?options : MorganOptions) : Void;
	public static function token(type : String, callback : ClientRequest -> ServerResponse -> String) : Void;
}
// 