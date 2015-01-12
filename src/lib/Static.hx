package lib;

@:expose('Static')
class Static
{
	static var baseUrl = '';

	public static function map(name : String) {
		return baseUrl + name;
	}
}