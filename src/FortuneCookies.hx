package;

import haxecontracts.*;

class FortuneCookies implements HaxeContracts
{
	static var cookies = [
		"Conquer your fears or they will conquer you.",
		"Rivers need springs.",
		"Do not fear what you don't know.",
		"You will have a pleasant surprise.",
		"Whenever possible, keep it simple.",
	];

	public static function getFortune() {
		Contract.ensures(Std.is(Contract.result, String), "Fortune cookie wasn't a String");
		return cookies[Std.random(cookies.length)];
	}
}