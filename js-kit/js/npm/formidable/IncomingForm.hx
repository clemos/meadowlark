package js.npm.formidable;

import js.node.http.ClientRequest;

extern class IncomingForm
implements npm.Package.RequireNamespace<"formidable","~1.0.16">
{
	public var encoding : String;
	public var uploadDir : String;
	public var keepExtensions : Bool;
	public var type : String;
	public var maxFieldsSize : Int;
	public var maxFields : Int;
	public var hash : Bool;
	public var multiples : Bool;
	public var bytesReceived : Int;
	public var bytesExpected : Int;

	public var onPart : File -> Void;

	@:overload(function(req : ClientRequest, cb : Dynamic -> Dynamic -> Array<File> -> Void) : Void {})
	public function parse(req : ClientRequest, cb : Dynamic -> Dynamic -> File -> Void) : Void;

	public function on(event : String, cb : Dynamic) : Void;
}
