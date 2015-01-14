package js.npm.express;

import js.node.http.ClientRequest;

typedef CsurfOptions = {
	?value : ClientRequest -> String,
	?cookie : Bool,
	?ignoreMethods : Array<String>
}

/**
 * Requires either a session middleware or cookie-parser to be initialized first.
 */
extern class Csurf
implements npm.Package.Require<"csurf", "~1.6.5">
implements Middleware.IMiddleware<Request, Response>
{
	// Use in error handlers
	public inline static var errorCode = 'EBADCSRFTOKEN';

	public function new(?options : CsurfOptions) : Void;

	public inline static function csrfToken(req : ClientRequest) : String {
		return untyped req.csrfToken();
	}
}
