package handlers;

import js.npm.express.Request;
import js.npm.express.Response;

class Dealers
{
	public function new() {}

	public function dealers(req : Request, res : Response) {
		res.render('dealers', {
			apiKey: Credentials.instance.google.maps.apiKey
		});
	}
}