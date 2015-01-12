package js.npm.express;

extern class Cors
implements npm.Package.Require<"cors", "~2.5.2">
implements js.npm.connect.Middleware
{
	public function new(?options : {}) : Void;
}
