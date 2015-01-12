package models;

import js.npm.mongoose.macro.Manager;
import js.npm.mongoose.macro.Model;

typedef VacationSchema = {
    name: String,
    slug: String,
    category: String,
    sku: String,
    description: String,
    priceInCents: Float,
    tags: Array<String>,
    inSeason: Bool,
    available: Bool,
    ?requiresWaiver: Bool,
    maximumGuests: Int,
    ?notes: String,
    packagesSold: Int,
}

class VacationManager extends Manager<VacationSchema, Vacation>
{}

class Vacation extends Model<VacationSchema>
{
    public static function build() { 
        return VacationManager.build(Database.instance, "Vacation"); 
    }

	public function getDisplayPrice() {
		var num = priceInCents / 100;
		return "$" + untyped num.toFixed(2);
	}
}