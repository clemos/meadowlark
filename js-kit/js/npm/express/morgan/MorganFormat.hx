package js.npm.express.morgan;

@:enum abstract MorganFormat(String) from String to String {
	var combined = "combined";
	var common = "common";
	var dev = "dev";
	var short = "short";
	var tiny = "tiny";
}
