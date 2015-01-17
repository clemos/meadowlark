
package lib;

import js.support.Callback;
using StringTools;

class GeoCode 
{
	public static function find<T>(query : String, cb : Callback<T>) {
		var options = {
			hostname: 'maps.googleapis.com',
			path: '/maps/api/geocode/json?sensor=false&address=' + query.urlEncode()
		};

		Request.httpJson(options, function(err, data) {
			if(err != null) cb(err, null);

			var results : Array<Dynamic> = data.results;
			if(results.length > 0)
				cb(null, results[0].geometry.location);
			else
				cb("No results found", null);
		});
	}
}