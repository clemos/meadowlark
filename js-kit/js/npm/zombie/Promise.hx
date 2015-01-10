package js.npm.zombie;

extern class Promise
{
	public function then(then : Void -> Void) : Promise;
	public function done(done : Void -> Void) : Void;
}
