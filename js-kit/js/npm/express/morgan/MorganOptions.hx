package js.npm.express.morgan;

import js.node.http.ClientRequest;
import js.node.http.ServerResponse;
import js.node.stream.Writable;

typedef MorganOptions = {
	?immediate : Bool,
	?skip : ClientRequest -> ServerResponse -> Bool,
	?stream : IWritable,
}
