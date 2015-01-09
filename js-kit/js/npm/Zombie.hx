package js.npm;

extern class Zombie
extends js.npm.zombie.Browser #if !haxe3,#end
implements npm.Package.Require<"zombie", "~2.5.1">
{
	public function new(?options : Dynamic) : Void;
}
