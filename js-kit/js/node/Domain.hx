package js.node;

import js.node.events.EventEmitter;

extern class Domain
implements npm.Package.Require<"domain", "*">
{
	public static function create() : Domain;

	public function on(event : String, err : Dynamic -> Void) : Void;
	public function add(emitter : EventEmitter) : Void;
	public function run(fn : Dynamic) : Void;
}
