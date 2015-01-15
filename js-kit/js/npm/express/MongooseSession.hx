package js.npm.express;

import js.support.Callback;
import js.npm.express.Session.SessionStore;
import js.npm.mongoose.Mongoose;

extern class MongooseSession
implements npm.Package.Require<"mongoose-session", "*"> #if !haxe3,#end
implements SessionStore
{
	public function new(mongoose : Mongoose, ?options : {
		?ttl : Int,
		?modelName : String
	}) : Void;

	public function get(sid : String, callback : Callback<{}> ) : Void;
	public function set(sid : String, session : {}, callback : Callback0 ) : Void;
	public function destroy(sid : String, callback : Callback0 ) : Void;
}
