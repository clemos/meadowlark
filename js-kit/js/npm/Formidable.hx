package js.npm;

import js.npm.formidable.IncomingForm;

extern class Formidable
implements npm.Package.Require<"formidable", "~1.0.16">
{
	public function new() : Void;

	// TODO: How to use new formidable.IncomingForm() properly? Related to https://github.com/HaxeFoundation/haxe/issues/3441 ?
	public static inline function IncomingForm() : IncomingForm { 
		return untyped __js__("new require('formidable').IncomingForm()"); 
	}
}
