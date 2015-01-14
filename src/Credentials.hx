package ;

class Credentials
{
	public static var cookieSecret = "your cookie secret goes here";
	
	public static var gmail = {
		user: "Gmail username", 
		password: "Gmail password"
	};

	public static var mongo = {
		devolopment: {
			connectionString: 'mongodb://localhost/meadowlark'
		},
		production: {
			connectionString: 'mongodb://localhost/meadowlark'
		},		
	}

	public static var authProviders = {
		facebook: {
			development: {
				appId: 'https://developers.facebook.com/apps/',
				appSecret: 'https://developers.facebook.com/apps/'
			}
		}
	}
}
