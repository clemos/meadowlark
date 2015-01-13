package js.npm.connect;

import js.node.Http.HttpServerReq;
import js.node.http.ServerResponse;

typedef ConnectBundleBundle = {
	file: String,
	contents: Array<String>,
	?location: String
}

extern class ConnectBundle
implements npm.Package.Require<"connect-bundle", "~0.0.5">
implements js.npm.connect.Middleware
{
	public function new(options : {}) : Void;
}
