package js.npm;

extern class ExpressHandlebars
implements npm.Package.Require<"express-handlebars", "^1.1.0">
{
	public static function create(?config : {}) : ExpressHandlebars;

	public var engine : Dynamic;
}
