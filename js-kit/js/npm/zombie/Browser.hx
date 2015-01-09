package js.npm.zombie;

extern class Browser
{
	public function new(?options : Dynamic) : Void;

	public function clickLink(selector : String, ?then : Void -> Void) : Promise;
	public function field(selector : String) : js.html.Element;
	public function visit(url : String, ?then : Void -> Void) : Promise;
}
