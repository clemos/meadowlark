package models;

import js.npm.mongoose.macro.Manager;
import js.npm.mongoose.macro.Model;

typedef DealerSchema = {
	name: String,
	address1: String,
	?address2: String,
	city: String,
	state: String,
	zip: String,
	?country: String,
	?phone: String,
	?website: String,
	active: Bool,
	?geocodedAddress: String,
	?lat: Float,
	?lng: Float
};

class DealerManager extends Manager<DealerSchema, Dealer> {}

class Dealer extends Model<DealerSchema>
{
	public static function build() {
		return DealerManager.build(Database.instance, "Dealer"); 
	}

	public function getAddress(lineDelim = '<br>') {
		var addr = address1;
		if(address2 != null && ~/\S/.match(address2))
			addr += lineDelim + address2;

		addr += lineDelim + city + ', ' + state + ' ' + zip;
		addr += lineDelim + (country == null ? 'US' : country);
		return addr;
	}
}