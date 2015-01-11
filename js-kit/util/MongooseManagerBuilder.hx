package util;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.TypeTools;

using Lambda;

#if macro
class MongooseManagerBuilder
{
	macro static public function build() : Array<Field> {
		var fields = Context.getBuildFields();

		var baseManagerType = "js.npm.mongoose.macro.Manager";
		var baseModelType = "js.npm.mongoose.macro.Model";

		var cls = Context.getLocalClass().get();
		var schema = schemaTypeFromModel(cls);
		
		var baseModel = switch Context.getType(baseModelType) {
			case TInst(t, params): t;
			case _: Context.error('$baseModelType not found.', Context.currentPos());
		};

		var baseManager = switch Context.getType(baseManagerType) {
			case TInst(t, params): t.get();
			case _: Context.error('$baseManagerType not found.', Context.currentPos());
		};

		var concreteManager = {
			sub: null,
			params: [
				TPType(Context.toComplexType(schema)), 
				TPType(Context.toComplexType(Context.getLocalType()))
			],
			pack: baseManager.pack,
			name: baseManager.name
		};

		var manager = {
			pos: Context.currentPos(),
			params: null,
			pack: cls.pack,
			name: cls.name + 'Manager',
			meta: null,
			kind: TDClass(concreteManager, [], false),
			isExtern: false,
			fields: []
		};

		Context.defineType(manager);

		var build = macro function build(mongoose) {
			return AttractionManager.build(mongoose, "Attraction");
		};

		fields.push({
			pos: Context.currentPos(),
			name: "build",
			meta: null,
			kind: FFun({
				ret: 
			})
		});

		return fields;
	}

	static function schemaTypeFromModel(cls : ClassType) : Type {
		var superClass = cls.superClass.t.get();

		if(superClass.name != 'Model')
			Context.error("Class must extend Model<T> with a Mongoose schema typedef as parameter.", Context.currentPos());	

		return cls.superClass.params[0];
	}
}
#end