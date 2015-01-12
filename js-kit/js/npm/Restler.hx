package js.npm;

import js.node.http.Server;
import js.node.http.ServerResponse;
import js.npm.nodemailer.Transport;
import js.npm.nodemailer.Transporter;

extern class RestlerResponse
{
	@:overload(function(event : String, callback : Void -> Void) : RestlerResponse {})	
	@:overload(function(event : String, callback : Dynamic -> Void) : RestlerResponse {})	
	public function on(event : String, callback : Dynamic -> ServerResponse -> Void) : RestlerResponse;
}

extern class Restler
implements npm.Package.Require<"restler", "~3.2.2">
{
	public static function request(url : String, ?options : {}) : RestlerResponse;
	public static function get(url : String, ?options : {}) : RestlerResponse;
	public static function post(url : String, ?options : {}) : RestlerResponse;
	public static function put(url : String, ?options : {}) : RestlerResponse;
	public static function del(url : String, ?options : {}) : RestlerResponse;
	public static function head(url : String, ?options : {}) : RestlerResponse;
	public static function patch(url : String, ?options : {}) : RestlerResponse;
	public static function json(url : String, data : Dynamic, ?options : {}) : RestlerResponse;
	public static function postJson(url : String, data : Dynamic, ?options : {}) : RestlerResponse;
	public static function putJson(url : String, data : Dynamic, ?options : {}) : RestlerResponse;
}
