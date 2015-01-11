package models;

import js.npm.mongoose.macro.Manager;
import js.npm.mongoose.macro.Model;

typedef AttractionSchema = {
	name: String,
	description: String,
	location: { lat: Float, lng: Float },
	history: {
		event: String,
		notes: String,
		email: String,
		date: Date,
	},
	updateId: String,
	approved: Bool
}

class AttractionManager extends Manager<AttractionSchema, Attraction>
{}

class Attraction extends Model<AttractionSchema>
{
	public static function build(mongoose) {
		return AttractionManager.build(mongoose, "Attraction"); 
	}
}