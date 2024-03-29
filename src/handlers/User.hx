package handlers;

import js.npm.express.Middleware.MiddlewareNext;
import js.npm.express.Request;
import js.npm.express.Response;
import js.npm.express.Session;
import js.npm.Passport;

class User
{
	public function new() {}

	public function customerOnly(req : Request, res : Response, next : MiddlewareNext) {
		var user = Passport.user(req);
		if(user != null && user.role == 'customer') next();
		else res.redirect(303, '/unauthorized');
	}

	public function employeeOnly(req : Request, res : Response, next : MiddlewareNext) {
		var user = Passport.user(req);
		if(user != null && user.role == 'employee') next();
		else next('route');
	}

	public function account(req : Request, res : Response, next : MiddlewareNext) {
		var user = Passport.user(req);
		res.render('user/account', {user: user});
	}

	public function orderHistory(req : Request, res : Response, next : MiddlewareNext) {
		res.render('user/account/order-history');
	}

	public function emailPrefs(req : Request, res : Response, next : MiddlewareNext) {
		res.render('user/account/email-prefs');
	}	

	public function sales(req : Request, res : Response, next : MiddlewareNext) {
		res.render('sales');
	}	
}