package js.npm.connect;

import js.npm.connect.Middleware;
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
implements npm.Package.Require<"connect-rest", "~1.6.0">
{
	public static function rester(?options : {}) : Middleware;

	@:overload(function<T>(path : Dynamic, cb : T -> Void) : Void {})
	@:overload(function<T>(path : Dynamic, cb : ConnectRestResult<T>) : Void {})
	public static function get<T>(path : Dynamic, cb : ConnectRestResult2<T>) : Void;

	@:overload(function<T>(path : Dynamic, cb : T -> Void) : Void {})
	@:overload(function<T>(path : Dynamic, cb : ConnectRestResult<T>) : Void {})
	public static function post<T>(path : Dynamic, cb : ConnectRestResult2<T>) : Void;
}
