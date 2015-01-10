package js.npm.express;

import js.node.http.ClientRequest;
import js.node.http.ServerResponse;

extern class ErrorHandler
implements npm.Package.Require<"errorhandler", "~1.3.2">
implements js.npm.connect.Middleware
{
	@:overload(function(?options : Bool) : Void {})
	public function new(?options: {
		log: Dynamic -> ?String -> ?ClientRequest -> ?ServerResponse -> Void
	}) : Void;
}
