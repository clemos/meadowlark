package ;

import haxecontracts.ContractException;
import js.Error;
import js.Node;

class Logger
{
	public static var instance : Logger = new Logger();

	var console : js.node.stdio.Console;

	public function new() {
		this.console = Node.console;
	}

	public function log( s : Dynamic , ?a1 : Dynamic , ?a2 : Dynamic , ?a3 : Dynamic ) {
		console.log(s, a1, a2, a3);
	}

	public function error(o : Dynamic) {
		if(Std.is(o, Error)) {
			logException(cast o);
		} else if(Std.is(o, ContractException)) {
			logContractException(cast o);
		} else {
			console.error("Error:");
			console.error(o);
		}
		console.error("-----");
	}

	private function logException(err : Error) {
		console.error("Exception:");
		console.error(err.stack);
	}

	private function logContractException(e : ContractException) {
		console.error("ContractException:");
		console.error(e.message);
		console.error(e.object);
		for (s in e.callStack) switch s {
			case FilePos(s, file, line): console.error('$file:$line');
			case _:
		}
	}	
}