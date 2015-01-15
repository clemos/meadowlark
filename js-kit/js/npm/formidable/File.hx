package js.npm.formidable;

extern class File
implements npm.Package.RequireNamespace<"formidable", "^1.0.16">
{
	public var size : Int;
	public var path : String;
	public var name : String;
	public var type : String;
	public var lastModifiedDate : Date;
	public var hash : String;
	
	public function toJSON() : Dynamic;
}
