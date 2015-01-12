package handlers.api;

import js.npm.express.BodyParser;
import js.npm.express.Request;
import js.npm.express.Response;
import models.Attraction;
import models.Attraction.AttractionManager;

class Attractions
{
	var attractions : AttractionManager;

	public function new() {
		attractions = Attraction.build();
	}

	public function get(req : Request, res : Response) {
		attractions.find({approved: true}, function(err, attractions) {
			if(err != null) return res.send(500, "Error: Database error.");
			res.json(attractions.map(function(a) return {
				name: a.name,
				id: a._id,
				description: a.description,
				location: a.location
			}));
		});
	}

	public function getById(req : Request, res : Response) {
		attractions.findById(req.params.id, function(err, a) {
			if(err != null) return res.send(500, "Error: Database error.");
			res.json({
				name: a.name,
				id: a._id,
				description: a.description,
				location: a.location
			});
		});
	}

	public function post(req : Request, res : Response) {
		var body = BodyParser.body(req);
		var d = Date.now();

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
		}).save(function(err, a){
			if(err != null) return res.send(500, 'Error occurred: database error.');
			res.json({ id: a._id });
		});
	}
}