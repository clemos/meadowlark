package js.npm;

import js.node.http.Server;
import js.node.http.ServerResponse;

extern class PuntListener
{
	public function on(event : String, callback : Dynamic -> Void) : Void;
}

extern class PuntSender
{
	public function send(data : Dynamic) : Void;	
}

extern class Punt
implements npm.Package.Require<"punt", "^2.2.0">
{
	public static function bind(address : String) : PuntListener;
	public static function connect(address : String) : PuntSender;
}
