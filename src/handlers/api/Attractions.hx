package handlers.api;

import js.npm.ConnectRest.ConnectRestCallback;
import js.npm.express.BodyParser;
import models.Attraction;
import models.Attraction.AttractionManager;

class Attractions
{
	var attractions : AttractionManager;

	public function new() {
		attractions = Attraction.build();
	}

	public function get(req, content, cb : ConnectRestCallback) {
		attractions.find({approved: true}, function(err, attractions) {
			if(err != null) return cb({error: "Internal error."});

			cb(null, attractions.map(function(a) return {
				name: a.name,
				//id: a._id,
				description: a.description,
				location: a.location
			}));
		});
	}

	public function getById(req, content, cb : ConnectRestCallback) {
		attractions.findById(req.params.id, function(err, a) {
			if(err != null) return cb({error: "Unable to retrieve attraction."});

			cb(null, toJSON(cast a));
		});
	}

	public function post(req, content, cb : ConnectRestCallback) {
		var body = BodyParser.body(req);
		var d = Date.now(); // Cannot put directly in the call to construct. See https://github.com/clemos/haxe-js-kit/issues/25

		attractions.construct({
			name: body.name,
			description: body.description,
			location: { lat: body.lat, lng: body.lng },
			history: {
				event: 'created',
				email: body.email,
				date: d
			},
			approved: false
		}).save(function(err, a) {
			Logger.instance.log(cb);
			if(err != null) return cb({error: 'Unable to add attraction.'});
			cb(null, { id: a._id });
		});
	}

	private static function toJSON(a : Attraction) {
		return {
			name: a.name,
			//id: a._id,
			description: a.description,
			location: a.location
		};
	}
}