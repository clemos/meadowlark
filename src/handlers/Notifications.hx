package handlers;

import js.npm.express.BodyParser;
import js.npm.express.Request;
import js.npm.express.Response;
import js.npm.express.Session;
import js.npm.mongoose.Mongoose;
import models.VacationInSeasonListener;

class Notifications
{
	var db : Mongoose;
	var logger : Logger;

	public function new(db) {
		this.db = db;
		this.logger = Logger.instance;
	}

	public function notifyMe(req : Request, res : Response) {
		res.render('notify-me-when-in-season', { sku: req.query.sku });
	}

	public function notifyMeSubmission(req : Request, res : Response) {
		var listeners = VacationInSeasonListener.build(db);
		var session = Session.session(req);
		var form = BodyParser.body(req);

		listeners.update(
			{email: form.email},
			{"$push": { skus: form.sku }},
			{upsert: true},
			function(err, listeners) {
				if(err != null) {
					logger.error(err);
					session.flash = {
						type: 'danger',
						intro: 'Ooops!',
						message: 'There was an error processing your request.',
					};
					return res.redirect(303, '/vacations');
				}
				session.flash = {
					type: 'success',
					intro: 'Thank you!',
					message: 'You will be notified when this vacation is in season.',
				};

				return res.redirect(303, '/vacations');				
			}
		);
	}
}