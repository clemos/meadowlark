package js.npm;

extern class ExpressHandlebars
implements npm.Package.Require<"express-handlebars", "*">
{
	public static function create(?config : Dynamic) : ExpressHandlebars;

	public var engine : Dynamic;
}
