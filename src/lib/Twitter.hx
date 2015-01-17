package lib;

import haxe.Json;
import js.Error;
import js.node.Https;
import js.node.Querystring;

class Twitter
{
	static var _a : String;
	static function accessToken(?v : String) : String {
		if(v != null) _a = v;
		return _a;
	}

	var options : {};

	public function new(?options : {}) {
		this.options = options;
	}

	private function result(cb, err, data) {
		if(err != null) throw new Error("Twitter request failed.");
		else cb(data);
	}

	public function search(query, count, cb) {
		getAccessToken(function(token) {
			if(token == null) cb(null);
			var options = {
				hostname: 'api.twitter.com',
				port: 443,
				method: 'GET',
				path: '/1.1/search/tweets.json?q=' +
					  StringTools.urlEncode(query) +
					  '&count=' + (count == null ? 10 : count),
				headers: {
					Authorization: 'Bearer ' + token
				}
			};

			Request.httpsJson(options, result.bind(cb));
		});
	}

	public function embed(statusId, ?options : Dynamic, cb) {
		if(options == null) options = {};
		options.id = statusId;
		
		getAccessToken(function(token) {
			if(token == null) cb(null);
			var requestOptions = { 
				hostname: 'api.twitter.com',
				port: 443,
				method: 'GET',
				path: '/1.1/statuses/oembed.json?q=' +
					  Querystring.stringify(options),
				headers: {
					Authorization: 'Bearer ' + token
				}
			};

			Request.httpsJson(requestOptions, result.bind(cb));
		});
	}

	function getAccessToken(cb : String -> Void) {
		if(accessToken() != null) {
			cb(accessToken());
			return;
		}

		var bearerToken = new js.node.Buffer(
			StringTools.urlEncode(Credentials.instance.twitter.consumerKey) + ":" +
			StringTools.urlEncode(Credentials.instance.twitter.consumerSecret)
		).toString('base64');

		var options = {
			hostname: 'api.twitter.com',
			port: 443,
			method: 'POST',
			path: '/oauth2/token?grant_type=client_credentials',
			headers: {
				Authorization: 'Basic ' + bearerToken
			}
		};

		Request.httpsJson(options, function(err, auth) {
			if(err != null || auth.token_type != 'bearer') {
				throw new Error("Twitter request failed.");
			} else {
				accessToken(auth.access_token);
				cb(accessToken());
			}
		});
	}
}