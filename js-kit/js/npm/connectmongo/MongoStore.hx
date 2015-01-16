package js.npm.connectmongo;

import js.npm.mongoose.Connection;
import js.support.Callback;

typedef MongoStoreOptions = {
	?mongooseConnection : Connection,
	?db : Dynamic,
	?url : String,
	?mongoOptions : Dynamic,
	?host : String,
	?port : Int,
	?username : String,
	?password : String,
	?autoReconnect : Bool,
	?w : Int,
	?ssl : Bool,
	?ttl : Int,
	?autoRemove : String,
	?autoRemoveInterval : Int,
	?collection : Dynamic,
	?stringify : Bool,
	?serialize : Dynamic,
	?unserialize : Dynamic,
	?hash : {salt: String, algorithm: String}
};

extern class MongoStore
implements npm.Package.RequireNamespace<"connect-mongo", "^0.6.0"> #if !haxe3,#end
implements js.npm.express.Session.SessionStore
{
	public inline static function create(?options : MongoStoreOptions) : MongoStore {
		return untyped __js__("new (require('connect-mongo')(require('express-session')))")(options);
	}

	public function get(sid : String, callback : Callback<{}> ) : Void;
	public function set(sid : String, session : {}, callback : Callback0 ) : Void;
	public function destroy(sid : String, callback : Callback0 ) : Void;	
}
