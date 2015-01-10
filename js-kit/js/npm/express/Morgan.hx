package js.npm.express;

import js.npm.express.morgan.MorganFormat;
import js.npm.express.morgan.MorganOptions;
import js.node.http.ClientRequest;
import js.node.http.ServerResponse;

extern class Morgan
implements npm.Package.Require<"morgan", "~1.5.1">
implements js.npm.connect.Middleware
{
	public function new(format : MorganFormat, ?options : MorganOptions) : Void;
	public static function token(type : String, callback : ClientRequest -> ServerResponse -> String) : Void;
}
// 