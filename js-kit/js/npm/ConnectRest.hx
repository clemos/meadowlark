package js.npm;

import js.npm.express.Middleware;
import js.npm.express.Request;
import js.npm.express.Response;

import js.npm.nodemailer.Transport;
import js.npm.nodemailer.Transporter;

typedef ConnectRestRequest = {
	headers: Dynamic,
	parameters: Dynamic,
	files: Dynamic,
	session: Dynamic
}

typedef ConnectRestCallback = Dynamic -> ?Dynamic -> ?Dynamic -> Void;

typedef ConnectRestResult<T> = T -> Dynamic -> Void;
typedef ConnectRestResult2<T> = T -> Dynamic -> ConnectRestCallback -> Void;

extern class ConnectRest
implements npm.Package.Require<"connect-rest", "^1.6.6">
{
	public static function rester(?options : {}) : Middleware<Request, Response>;

	@:overload(function<T>(path : Dynamic, cb : T -> Void) : Void {})
	@:overload(function<T>(path : Dynamic, cb : ConnectRestResult<T>) : Void {})
	public static function get<T>(path : Dynamic, cb : ConnectRestResult2<T>) : Void;

	@:overload(function<T>(path : Dynamic, cb : T -> Void) : Void {})
	@:overload(function<T>(path : Dynamic, cb : ConnectRestResult<T>) : Void {})
	public static function post<T>(path : Dynamic, cb : ConnectRestResult2<T>) : Void;
}
