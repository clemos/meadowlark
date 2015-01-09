package js.npm.zombie;

extern class Promise
implements npm.Package.RequireNamespace<"zombie","~2.5.1">
{
	public function then(then : Void -> Void) : Promise;
	public function done(done : Void -> Void) : Void;
}
