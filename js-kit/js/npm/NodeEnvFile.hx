package js.npm;

typedef NodeEnvFileOptions = {
	?verbose: Bool,
	?overwrite: Bool
}

extern class NodeEnvFile
implements npm.Package.Require<"node-env-file", "^0.1.4">
{
	public function new(filePath : String, ?options : NodeEnvFileOptions) : Void;
}
