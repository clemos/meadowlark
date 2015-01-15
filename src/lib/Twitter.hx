package lib;

import haxe.Json;
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

			makeRequest(options, cb);
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

			makeRequest(requestOptions, cb);
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

		makeRequest(options, function(auth) {
			if(auth.token_type != 'bearer') {
				cb(null);
			} else {
				accessToken(auth.access_token);
				cb(accessToken());
			}
		});
	}

	function makeRequest(options, cb : Dynamic -> Void) {
		var req = Https.request(options, function(res) {
			var data = '';
			res.on('data', function(chunk) data += chunk);
			res.on('end', function() cb(Json.parse(data)));
		});
		req.end();
	}
}