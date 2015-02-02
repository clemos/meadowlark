package handlers;

import js.npm.express.Request;
import js.npm.express.Response;
import js.npm.express.Session;
import js.npm.mongoose.Mongoose;
import models.Vacation;

class Vacations
{
	var db : Mongoose;

	public function new() {
		this.db = Database.instance;
	}

	public function setCurrency(req : Request, res : Response) {
		var session = Session.session(req);
		session.currency = req.params.currency;
		res.redirect(303, '/vacations');
	}

	public function vacations(req : Request, res : Response) {
		var vacation = Vacation.build();
		var session = Session.session(req);

		var convertFromUSD = function(value : Float, currency) {
			return switch(currency) {
				case "USD": "$" + value * 1;
				// Note: Using a pound sign here
				// gives autocompletion problems in Sublime!
				case "GBP": "&#163;" + value * 0.6;
				case "BTC": "B" + value * 0.0023707918444761;
				case _: null;
			};
		};

		vacation.find({available: true}, function(err, vacations) {
			var currency = session.currency == null ? 'USD' : session.currency;
			var context = {
				currency: currency,
				vacations: vacations.map(function(vacation) {
					return {
						sku: vacation.sku,
						name: vacation.name,
						description: vacation.description,
						price: convertFromUSD(vacation.priceInCents / 100, currency),
						inSeason: vacation.inSeason
					}
				})
			};

			var field = switch(currency) {
				case 'GBP': 'currencyGBP';
				case 'BTC': 'currencyBTC';
				case _: 'currencyUSD';
			}

			Reflect.setField(context, field, 'selected');
			res.render('vacations', context);
		});	
	}
}