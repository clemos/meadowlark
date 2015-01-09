package js.npm.formidable;

import js.npm.express.Request;

extern class IncomingForm
implements npm.Package.RequireNamespace<"formidable","~1.0.16">
{
	@:overload(function(req : Request, cb : Dynamic -> Dynamic -> Array<File> -> Void) : Void {})
	public function parse(req : Request, cb : Dynamic -> Dynamic -> File -> Void) : Void;
}
