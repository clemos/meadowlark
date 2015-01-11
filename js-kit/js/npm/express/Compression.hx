package js.npm.express;

extern class Compression
implements npm.Package.Require<"compression", "~1.10.1">
implements js.npm.connect.Middleware
{
	public function new(?options : {}) : Void;
}
