
package lib;

import haxe.Json;
import js.support.Callback;
import js.node.Http;
import js.node.Http.HttpReqOpt;
import js.node.Https;
import js.node.Https.HttpsReqOpt;
import js.support.Either;

class Request 
{
	public static function httpJson<T>(options : HttpReqOpt, cb : Callback<T>, autoEndReq = true) {
		var req = Http.request(options, parseJson.bind(cb));
		if(autoEndReq) req.end();
		return req;
	}

	public static function httpsJson<T>(options : HttpsReqOpt, cb : Callback<T>, autoEndReq = true) {
		var req = Https.request(options, parseJson.bind(cb));
		if(autoEndReq) req.end();
		return req;
	}

	static function parseJson<T>(cb : Callback<T>, res) {
		var data = new StringBuf();
		res.on('data', data.add);
		res.on('error', function(err) cb(err, null));
		res.on('end', function(_) cb(null, Json.parse(data.toString())));
	}
}
