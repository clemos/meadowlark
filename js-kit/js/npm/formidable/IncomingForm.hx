package js.npm.formidable;

import js.node.http.ClientRequest;

class IncomingFormHelper
{
	/**
	 * Ensures that the form is parsed only once. Useful when accessing the form
	 * in several middlewares.
	 */ 
	public static function parse<Req : ClientRequest>(
		req : Req, 
		cb : Dynamic -> Dynamic -> Dynamic<File> -> Void) : IncomingForm<Req>
	{
		var form : Dynamic = untyped req.incomingForm;

		if(form == null) {
			form = untyped req.incomingForm = {form: new IncomingForm()};
			form.form.parse(req, function(err, fields, files) {
				form.err = err;
				form.fields = fields;
				form.files = files;

				cb(err, fields, files);
			});
		} else {
			cb(form.err, form.fields, form.files);
		}

		return form.form;
	}
}

@:enum abstract IncomingFormEvent(String) from String to String {
	var progress = "progress";
	var field = "field"; 
	var fileBegin = "fileBegin"; 
	var file = "file"; 
	var error = "error"; 
	var aborted = "aborted"; 
	var end = "end";
}

extern class IncomingForm<Req : ClientRequest>
implements npm.Package.RequireNamespace<"formidable", "^1.0.16">
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

	public function parse(req : Req, ?cb : Dynamic -> Dynamic -> Dynamic<File> -> Void) : Void;

	public function on(event : IncomingFormEvent, cb : Dynamic) : Void;

	public function new() : Void;
}
