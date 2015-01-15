package js.npm;

import js.npm.express.Request;
import js.npm.express.Response;
import js.npm.express.Middleware.IMiddleware;

typedef ConnectBundleBundle = {
	file: String,
	contents: Array<String>,
	?location: String
}

extern class ConnectBundle
implements npm.Package.Require<"connect-bundle", "~0.0.5">
implements IMiddleware<Request, Response>
{
	public function new(options : {}) : Void;
}
