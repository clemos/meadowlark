package handlers;

import js.Error;
import js.Node;
import js.npm.connect.support.Middleware;
import js.npm.express.BodyParser;
import js.npm.express.Request;
import js.npm.express.Response;
import js.npm.express.Session;
import js.npm.mongoose.Mongoose;

class Cart
{
	static var VALID_EMAIL_REGEX = ~/^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$/;

	var mailer : js.npm.nodemailer.Transporter;
	var console : js.node.stdio.Console;

	public function new(mailer) {
		this.mailer = mailer;
		this.console = Node.console;
	}

	public function checkout(req : Request, res : Response, next : MiddlewareNext) {
		var cart : Dynamic = Session.session(req).cart;
		var form = BodyParser.body(req);
		if(!cart) next(new Error('Cart does not exist.'));

		var name = form.name == null ? '' : form.name;
		var email = form.name == null ? '' : form.email;

		// input validation
		if(!VALID_EMAIL_REGEX.match(email))
			return next(new Error('Invalid email address.'));

		// assign a random cart ID; normally we would use a database ID here
		cart.number = ~/^0\.0*/.replace(Std.string(Math.random()), '');
		cart.billing = {
			name: name,
			email: email,
		};

		res.render('email/cart-thank-you', {layout: null, cart: cart}, function(err, html) {
			if(err != null) console.log('error in email template');

			mailer.sendMail({
				from: '"Meadowlark Travel": info@meadowlarktravel.com',
				to: cart.billing.email,
				subject: 'Thank You for Book your Trip with Meadowlark',
				html: html,
				generateTextFromHtml: true
			}, function(err : Dynamic){
				if(err) console.error('Unable to send confirmation: ' + err.stack);
			});
		});

		res.render('cart-thank-you', { cart: cart });
	}
}