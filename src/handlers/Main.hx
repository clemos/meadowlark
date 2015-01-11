package handlers;

import js.npm.express.Request;
import js.npm.express.Response;

class Main
{
	public function new() {}

	public function home(req : Request, res : Response) {
		res.render('home');
	}

	public function about(req : Request, res : Response) {
		res.render('about', {
			fortune: FortuneCookies.getFortune(),
			pageTestScript: '/qa/tests-about.js'
		});
	}
}