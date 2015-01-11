package js.npm;

import js.node.http.Server;
import js.node.http.ServerResponse;
import js.npm.nodemailer.Transport;
import js.npm.nodemailer.Transporter;

extern class RestResponse
{
	@:overload(function(event : String, callback : Void -> Void) : Void {})	
	@:overload(function(event : String, callback : Dynamic -> Void) : Void {})	
	public function on(event : String, callback : Dynamic -> ServerResponse -> Void) : Void;
}

extern class Restler
implements npm.Package.Require<"restler", "~3.2.2">
{
	public static function request(url : String, ?options : {}) : RestResponse;
	public static function get(url : String, ?options : {}) : RestResponse;
	public static function post(url : String, ?options : {}) : RestResponse;
	public static function put(url : String, ?options : {}) : RestResponse;
	public static function del(url : String, ?options : {}) : RestResponse;
	public static function head(url : String, ?options : {}) : RestResponse;
	public static function patch(url : String, ?options : {}) : RestResponse;
	public static function json(url : String, data : Dynamic, ?options : {}) : RestResponse;
	public static function postJson(url : String, data : Dynamic, ?options : {}) : RestResponse;
	public static function putJson(url : String, data : Dynamic, ?options : {}) : RestResponse;
}
