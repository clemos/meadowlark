package models;

import js.npm.mongoose.macro.Manager;
import js.npm.mongoose.macro.Model;

typedef UserSchema = {
	authId: String,
	name: String,
	?email: String,
	role: String,
	created: Date
}

class UserManager extends Manager<UserSchema, User> {}

class User extends Model<UserSchema>
{
	public static function build() {
		return UserManager.build(Database.instance, "User"); 
	}
}
