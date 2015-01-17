package ;

import js.Node;

/**
 * Use www/.env to set the environment variables in this file.
 * Using https://www.npmjs.com/package/node-env-file
 */
class Credentials
{
	public static var instance(default, null) : Credentials;

	public static function create(env) {
		instance = new Credentials(env);
	}

	var env : Dynamic;

	public var cookieSecret : String;
	public var google : Dynamic;
	public var mongo : Dynamic;
	public var authProviders : Dynamic;
	public var twitter : Dynamic;
	public var wunderground : Dynamic;

	private function new(env) {
		this.env = env;

		this.cookieSecret = "your cookie secret goes here";

		this.wunderground = {
			apiKey: env.WUNDERGROUND_APIKEY
		}

		this.google = {
			gmail: {
				user: env.GMAIL_USER, 
				password: env.GMAIL_PASSWORD
			},
			maps: {
				apiKey: env.GOOGLE_MAPS_APIKEY
			}
		};

		this.mongo = {
			development: {
				connectionString: 'mongodb://localhost/meadowlark'
			},
			production: {
				connectionString: 'mongodb://localhost/meadowlark'
			}
		}

		this.authProviders = {
			facebook: {
				development: {
					appId: env.FB_APPID,
					appSecret: env.FB_APPSECRET
				}
			}
		}

		this.twitter = {
			consumerKey: env.TWITTER_CONSUMERKEY, 
			consumerSecret: env.TWITTER_CONSUMERSECRET
		};
	}
}
