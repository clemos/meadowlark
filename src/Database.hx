package ;

import js.Node;
import js.npm.Express;
import models.Vacation;

class Database
{
	public static var instance : js.npm.mongoose.Mongoose;

	public static function connect(app : Express, ?options) {
		if(options == null) {
			options = {
				server: {
					socketOptions: { keepAlive: 1 }
				}
			};
		}

		var mongoose = js.npm.Mongoose.mongoose;

		switch(app.get('env')) {
			case 'development':
				instance = mongoose.connect(Credentials.mongo.devolopment.connectionString, cast options);
			case 'production':
				instance = mongoose.connect(Credentials.mongo.production.connectionString, cast options);
			case _:
				throw new js.Error('Unknown execution environment: ' + app.get('env'));
		}

		return instance;
	}

	public static function seed() {
		var vacation = Vacation.build();

		vacation.find(function(err, vacations) {
			if(vacations.length > 0) return;

			Logger.instance.log("Seeding database...");

			vacation.construct({
				name: 'Hood River Day Trip',
				slug: 'hood-river-day-trip',
				category: 'Day Trip',
				sku: 'HR199',
				description: 'Spend a day sailing on the Columbia and ' +
					'enjoying craft beers in Hood River!',
				priceInCents: 9995,
				tags: ['day trip', 'hood river', 'sailing', 'windsurfing', 'breweries'],
				inSeason: true,
				maximumGuests: 16,
				available: true,
				packagesSold: 0
			}).save();

			vacation.construct({
				name: 'Oregon Coast Getaway',
				slug: 'oregon-coast-getaway',
				category: 'Weekend Getaway',
				sku: 'OC39',
				description: 'Enjoy the ocean air and quaint coastal towns!',
				priceInCents: 269995,
				tags: ['weekend getaway', 'oregon coast', 'beachcombing'],
				inSeason: false,
				maximumGuests: 8,
				available: true,
				packagesSold: 0
			}).save();

			vacation.construct({
				name: 'Rock Climbing in Bend',
				slug: 'rock-climbing-in-bend',
				category: 'Adventure',
				sku: 'B99',
				description: 'Experience the thrill of climbing in the high desert.',
				priceInCents: 289995,
				tags: ['weekend getaway', 'bend', 'high desert', 'rock climbing'],
				inSeason: true,
				requiresWaiver: true,
				maximumGuests: 4,
				available: false,
				packagesSold: 0,
				notes: 'The tour guide is currently recovering from a skiing accident.'
			}).save();

			Logger.instance.log("Seeding completed.");
		});
	}		
}