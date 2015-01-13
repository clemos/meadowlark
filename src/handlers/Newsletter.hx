package handlers;

import js.Node;
import js.npm.express.BodyParser;
import js.npm.express.Request;
import js.npm.express.Response;

class Newsletter
{
	var console : js.node.stdio.Console;

	public function new() {
		this.console = Node.console;
	}

	public function newsletter(req : Request, res : Response) {
		res.render('newsletter');
	}

	public function process(req : Request, res : Response) {
		var form = BodyParser.body(req);

		console.log('Form (from querystring): ' + req.query.form);
		console.log('CSRF token (from hidden form field): ' + form._csrf);
		console.log('Name (from visible form field): ' + form.name);
		console.log('Email (from visible form field): ' + form.email);

		if(req.xhr || req.accepts('json,html') == 'json'){
			// if there were an error, we would send { error: 'error description' }
			res.send({ success: true });
		} else {
			// if there were an error, we would redirect to an error page
			res.redirect(303, '/thank-you');
		}
	}
}