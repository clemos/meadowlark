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
}
