package js.npm.formidable;

extern class File
{
	public var size : Int;
	public var path : String;
	public var name : String;
	public var type : String;
	public var lastModifiedDate : Date;
	public var hash : String;
	
	public function toJSON() : Dynamic;
}
