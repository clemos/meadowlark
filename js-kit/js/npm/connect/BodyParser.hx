package js.npm.connect;

extern class BodyParser
implements npm.Package.Require<"body-parser", "~1.10.1">
implements js.npm.connect.Middleware
{
	public static function json(?options : Dynamic) : BodyParser;
	public static function raw(?options : Dynamic) : BodyParser;
	public static function text(?options : Dynamic) : BodyParser;
	public static function urlencoded(?options : Dynamic) : BodyParser;
}
