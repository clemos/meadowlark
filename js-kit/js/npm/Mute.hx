package js.npm;

import js.Node;

/**
 * Simple enough module to be ported.
 */
class Mute
{
	public static function mute(callback : (Void -> Void) -> Void) : Void {

		var process = Node.process;

		var stdout = process.stdout.write;
		var stderr = process.stderr.write;

		var unmute = function() {
			untyped process.stdout.write = stdout;
			untyped process.stderr.write = stderr;
		};

		untyped process.stdout.write = function() {};
		untyped process.stderr.write = function() {};

		try {
			callback(unmute);
		} catch (e : Dynamic) {
			unmute();
			throw e;
		}
	}
}
